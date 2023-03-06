//
//  Category.swift
//  Todoey
//
//  Created by 内田麻美 on 2023/03/02.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

//スーパークラスをObject、Realmを使って保存できる
//dynamicは動的な変数、アプリ実行中にプロパティの変更を監視
class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    //リレーションシップを指定するためRealmのフレームワークのListで初期化
    let items = List<Item>()
    
}

