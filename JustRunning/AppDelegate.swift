//
//  AppDelegate.swift
//  Pace
//
//  Created by Ben Porter on 9/21/17.
//  Copyright © 2017 Ben Porter. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //move to each page instead
        UIApplication.shared.statusBarStyle = .lightContent
        
        //tab bar customization
        if self.window!.rootViewController as? UITabBarController != nil {
            let tababarController = self.window!.rootViewController as! UITabBarController
            tababarController.selectedIndex = 1
            tababarController.tabBar.shadowImage = UIImage()
            tababarController.tabBar.backgroundImage = UIImage()
            tababarController.tabBar.tintColor = UIColor.JustRunning.purple
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }




}

