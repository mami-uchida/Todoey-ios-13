//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    //アプリがロードされるときに、viewDidLoadの前に呼び出される。アプリケーション起動後のカスタマイズのポイントをオーバーライド。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            _ = try Realm()
        } catch {
            print("Error initialising new realm., \(error)")
        }
        return true
    }
}

