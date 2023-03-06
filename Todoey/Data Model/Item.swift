//
//  Iten.swift
//  Todoey
//
//  Created by 内田麻美 on 2023/03/02.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift


//スーパークラスをObject、Realmを使って保存できる
//dynamicは動的な変数、アプリ実行中にプロパティの変更を監視
class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    //リレーションシップを指定するためLinkingObjectsで項目の逆関係を定義し初期化
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
