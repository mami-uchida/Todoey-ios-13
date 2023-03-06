//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    //自動更新のResultsコンテナの型になるように宣言
    private var todoItems : Results<Item>?
    let realm = try! Realm()
    //テーブルビューにすべてのToDoリストを表示
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //Navigationについて触れるにはこのタイミング
    override func viewWillAppear(_ animated: Bool) {
        //guardでアンラップ
        guard let colorHex = selectedCategory?.color, let navBarColor = UIColor(hexString: colorHex) else { return}
        guard let navBar  = navigationController?.navigationBar else { fatalError("Navigation Controller does nor exist.") }
        
        title = selectedCategory!.name
        navBar.backgroundColor = UIColor(hexString: colorHex)
        navBar.backgroundColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - TableView Datasource Methods
    
    //Todoがnilでなければ持っているカテゴリの数を返す、nilなら1行のみ返す
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    //prototypeCellsを使用して作成され現在の行のテキストが入力されたcellはtableViewに返されて行として表示するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //スーパークラスにアクセスしcellForRowAt indexPathへアクセスし帰ってきたセルがここに戻ってくる
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let item = todoItems?[indexPath.row], let selectedCategory = selectedCategory, let todoItems = todoItems else {
            cell.textLabel?.text = "No Items added."
            return cell
        }
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        guard let color = UIColor(hexString: selectedCategory.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count)) else {
            return cell
        }
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        return cell
    }
    
    //MARK: - tableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = todoItems?[indexPath.row] else { return }
        do {
            //nilでなければRealmに書き込む
            try realm.write {
                //トグルし正反対の性質を持たせる
                item.done = !item.done
            }
        } catch {
            print("Error saving done status, \(error)")
        }
        //データソースメソッドを再度呼び出してテーブルビューを更新
        tableView.reloadData()
        //クリック後のセルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Add New Items
    
    //新しいToDo項目を追加する際に必要になる各種メソッド
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //TextFieldに入力された文を"Add Item"で使うためにUITextField()として初期化する
        var textField = UITextField()
        //"Add New Todoey Item"アラート画面のポップアップのために初期化する
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        //ポップアップに"Add Item"というアクションを追加
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //nilでなければcurrentCategory とし
            guard let currentCategory = self.selectedCategory else { return }
            do {
                try self.realm.write {
                    let newItem = Item()
                    //newItemにtitleをセット
                    newItem.title = textField.text!
                    //日時を取得しdateCreatedへ
                    newItem.dateCreated = Date()
                    //currentCategoryにアイテムを追加
                    currentCategory.items.append(newItem)
                }
            } catch {
                print("Error saving items, \(error)")
            }
            //新たに追加したすべてのデータでreloadData()しを更新
            self.tableView.reloadData()
        }
        //ポップアップアラート内にテキストを入力するフィールドを追加
        alert.addTextField { (alertTextField) in
            //Placeholderにあらかじめ "Create new item"としておく
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        //UIAlertActionクロージャ内にアクセスしUIAlertActionを表示
        alert.addAction(action)
        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    //searchBar内が変化、またはテキストが0になったときにトリガーされデータを取り出し
    func loadItems() {
        //titleをアルファベット順にソートしtodoItemsへ
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    //オーバーライドして呼び出し更新
    override func updateModel(at indexPath: IndexPath) {
        guard let item = todoItems?[indexPath.row] else { return }
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Error deleting items,\(error)")
        }
    }
}

// MARK: - SearchBar Methods

//拡張し、UISearchBarDelegateを動作させるためのデリゲートをセット
extension TodoListViewController : UISearchBarDelegate {
    //検索ボタンがクリックされた際の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //todoItemsの項目を"title CONTAINS[cd] %@"でフィルタリング、titleをアルファベット順に。
        todoItems = todoItems?.filter("title CONTAINS[cd] %@",  searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        //新しいデータでreloadData()
        tableView.reloadData()
    }
    //searchBar内が変化、またはテキストが0になったときに loadItems()をトリガー
    //最初にロードしたとき検索バーの中身が0の場合は「変化がない」と見なし、トリガーされない
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchBar.text?.count == 0 else { return }
        loadItems()
        //メインスレッドでデータベースへのコールを行うと処理に時間がかかり完了するまでアプリがフリーズしてしまう
        //タスクが完了するまでメインキューを取得する必要があり、タスクが完了する前でも検索バーを終了したいので DispatchQueueを使用
        DispatchQueue.main.async {
            //resignFirstResponder()
            searchBar.resignFirstResponder()
        }
    }
}

