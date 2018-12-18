//
//  AppDelegate.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        // Override point for customization after application launch.
        
        // 设置跟控制器
        //        创建一个字符串常量，作为是否启动过的标示名称
        let EVERLAUNCHED = "everlaunched"
        //        再创建一个字符串常量，作为首次启动的标识符名称
        let FIRSTLAUNCH = "firstlaunch"
        //        获得变量的布尔值，当程序首次启动时由于没有设置过变量，所以默认值为否
        if(!UserDefaults.standard.bool(forKey: EVERLAUNCHED))
        {
            //            将标识是否启动过的变量更该为真，标示程序至少被启动过一次
            UserDefaults.standard.set(true, forKey: EVERLAUNCHED)
            //            将标示是否首次启动的变量设为真，标示程序是首次启动
            UserDefaults.standard.set(true, forKey: FIRSTLAUNCH)
            //            调用同步方法，立即保存修改
            UserDefaults.standard.synchronize()
            let indexVC = GuideViewController()
            window?.rootViewController = indexVC
        }
        else{
            //            如果曾经启动过程序，则变量的布尔值为否
            UserDefaults.standard.set(false, forKey: FIRSTLAUNCH)
            //            调用同步方法，立即保存修改
            UserDefaults.standard.synchronize()
            window?.rootViewController = LoginViewController()
        }
        // 延迟进入应用,避免应用启动过快,导致启动图片一闪而过
        Thread.sleep(forTimeInterval: 3) // pause 2 sec before main storybord shows
        return true
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

