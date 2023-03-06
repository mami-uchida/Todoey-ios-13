//
//  categoryViewController.swift
//  Todoey
//
//  Created by 内田麻美 on 2023/03/01.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    private var categories : Results<Category>?
    override func viewDidLoad() {
        super.viewDidLoad()
        //現在所有しているすべてのカテゴリをロード
        loadCategories()
    }
    //Navigationについて触れるにはこのタイミング
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    // MARK: - TableView Datasource Methods
    //ToDoリストに表示させる項目の数分（この場合itemArray項目）のcellを作成するメソッド
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //nilでなければ持っているカテゴリの数を返す、nilなら1だけを返す
        return categories?.count ?? 1
    }
    //prototypeCellsを使用して作成され現在の行のテキストが入力されたcellはtableViewに返されて行として表示するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //スーパークラスにアクセスしcellForRowAt indexPathへアクセスし帰ってきたセルがここに戻ってくる
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let category = categories?[indexPath.row], let categoryColor = UIColor(hexString: category.color) else { fatalError() }
        //nilでなければtextLableのtextプロパティを設定
        cell.textLabel?.text = category.name
        // addButtonPressed内でカメレオンフレームワークで生成され保持された色をここで表示
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        return cell
    }
    
    //MARK: - TableVoew Delegate Methods
    
    //セルを選んだらdidSelectRowAtが実行されTodoListViewControllerに移動
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セグエのトリガー
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    //トリガー前に選択されたアイテムでitemArrayを初期化しセグエの準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TodoListViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
        //もしindexPathがnillでなければ目的のViewControllerをタップしてselectedCategoryというプロパティを設定
        //selectedCategoryへindexPathにあるカテゴリを格納
        destinationVC.selectedCategory = categories?[indexPath.row]
    }
    
    //MARK: - Data Manipulation
    
    //配列を保存。メソッドに渡す必要があるので(category: Category)
    func save(category: Category) {
        do {
            //一時的に調べてRealmに永続的にコミットを保存
            try realm.write {
                //メソッドに渡す
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)")
        }
        //reloadData()し表示させる
        tableView.reloadData()
    }
    
    //保存したデータを取り出しロード
    func  loadCategories() {
        //Realm内を検索しCategory型オブジェクトを読み込み自動更新させるためにcategoriesへ格納
        categories = realm.objects(Category.self)
        //リロードしcellForRowAtメソッドを再トリガーし新しいデータのcategoriesでtableviewを更新させる
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    //オーバーライドして呼び出し更新
    override func updateModel(at indexPath: IndexPath) {
        guard let categoryForDeletion = categories?[indexPath.row] else { return }
        do {
            try realm.write {
                realm.delete(categoryForDeletion)
            }
        } catch {
            print("Error deleting category,\(error)")
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //新しいカテゴリが追加されてたら参照を行うための変数
        var textField = UITextField()
        //"Add Todoey Category"アラート画面のポップアップのため初期化
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        //ポップアップに"Add Category"というアクションを追加
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            guard let text = textField.text else { return }
            let newCategory = Category()
            newCategory.name = text
            //カメレオンで色を生成した色をnewCategory.colorへ
            newCategory.color = UIColor.randomFlat().hexValue()
            //newCatagoryをRealmdデータベースに保存
            self.save(category: newCategory)
        }
        //UIAlertActionクロージャ内にアクセス
        alert.addAction(action)
        //テキストフィールドplaceholderの設定
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
}


