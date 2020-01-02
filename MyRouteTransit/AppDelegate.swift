//
//  AppDelegate.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2019/12/23.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        var operators = [TransportOperator]()
        let operatorBaseJsonPath = Bundle.main.path(forResource: "operators", ofType: "json")
        let operatorBaseJsonString = try! String(contentsOfFile: operatorBaseJsonPath!)
        
        let railwayDict = JSON(parseJSON: operatorBaseJsonString)
        for railway in railwayDict{
            let newOperator = TransportOperator()
            newOperator.operatorCode = railway.1["owl:sameAs"].stringValue
            newOperator.operatorName = railway.1["dc:title"].stringValue
            operators.append(newOperator)
        }
        let db = try! Realm()
        let objects = db.objects(TransportOperator.self)
        for i in operators{
            let currentOperatorData = objects.filter("operatorCode == %@", i.operatorCode)
            if currentOperatorData.count == 0{
                try! db.write {
                    db.add(i)
                }
            }else{
                try! db.write {
                    currentOperatorData[0].operatorName = i.operatorName
                }
            }
        }
        
        print(objects)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

