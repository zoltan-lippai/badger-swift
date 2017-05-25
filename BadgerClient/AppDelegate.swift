//
//  AppDelegate.swift
//  BadgerClient
//
//  Created by Anderthan Hsieh on 5/3/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let socketVC = NetworkingViewController(nibName: "SocketViewController", bundle: nil)
        self.window?.rootViewController = socketVC
        return true
    }
}

