//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by 内田麻美 on 2023/03/03.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView Datasource Methods
    
    //CategoryViewControllerのcellForRowAt indexPathメソッド部分がここのコード内をトリガーし、SwipeTableViewCellとして新しいcellを作成
    //WithIdentifierにはCategoryVCとTodoListVCの両方のPrototypeCellsの識別子Cellを,IndexPathにはtaleViewが入力しようとしている現在のindexPath
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SwipeTableViewCell else { return UITableViewCell()}
        //セルのデリゲートを現在のクラスであるSwipeTableViewControllerに設定
        cell.delegate = self
        //CategoryVIreController,TodoListViewControllerのcellForRowAt indexPathにセルを返す
        return cell
    }
    
    
    //セルをスワイプ
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        //右からのスワイプしたとき
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            //indexPathを渡してupdateModelを呼び出す
            self.updateModel(at: indexPath)
        }
        // セルをスワイプした時の画像
        deleteAction.image = UIImage(named: "delete-Icon")
        return [deleteAction]
    }
    
    //スワイプし削除
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
    }
}
