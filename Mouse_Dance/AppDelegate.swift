//
//  AppDelegate.swift
//  Mouse_Dance
//
//  Created by Anh Tuan on 7/24/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var listTitle = [String]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ControlViewController(nibName: "ControlViewController", bundle: nil)
        
        let scanningVC = ScanningViewController(nibName: "ScanningViewController", bundle: nil)
        
        let nav = UINavigationController(rootViewController: scanningVC)
        
        for i in 0 ..< 10 {
            self.listTitle.append("\(i + 1)")
        }
        
        let data = UserDefaults.standard.value(forKey: "TitleForRecord")
        if (data == nil){
            let dataText = self.convertDataToJSON()
            UserDefaults.standard.set(dataText, forKey: "TitleForRecord")
        }

        
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        
        return true
    }
    
    
    func convertBtnToJSON(item : String) -> String {
        return "{ \"Title\" : \"\(item)\"}"
    }
    
    func convertDataToJSON() -> String{
        var i = 0
        var result = "["
        for item in self.listTitle {
            let str = self.convertBtnToJSON(item: item)
            if (i != self.listTitle.count - 1) {
                result = result + str + ","
            } else {
                result = result + str + "]"
            }
            i = i + 1
        }
        return result
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

