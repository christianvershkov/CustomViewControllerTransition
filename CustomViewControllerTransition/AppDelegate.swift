//
//  AppDelegate.swift
//  CustomViewControllerTransition
//
//  Created by Christian Vershkov on 4/23/19.
//  Copyright © 2019 Christian Vershkov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let containerViewController = ContainerViewController(viewControllers: [FirstViewController(), SecondViewController(), FirstViewController(), SecondViewController()])
        window?.rootViewController = containerViewController
        window?.makeKeyAndVisible()
        
        return true
    }


}

