//
//  AppDelegate.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RecordService.shared.getLocalRecords()
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        //let splitVC = SplitVC(nibName: nil, bundle: nil)
        //splitVC.delegate = self
        
        //let masterVC = UINavigationController(rootViewController: MasterVC(nibName: nil, bundle: nil))
        //let detailVC = UINavigationController(rootViewController: DetailVC(nibName: nil, bundle: nil))
        //splitVC.viewControllers = [masterVC, detailVC]
        //let mainVC = UINavigationController(rootViewController: MainVC())
        window?.rootViewController = MainVC()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        RecordService.shared.saveRecordsLocally()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        RecordService.shared.saveRecordsLocally()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        RecordService.shared.saveRecordsLocally()
    }


}

