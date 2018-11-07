//
//  AppDelegate.swift
//  RendererExample
//
//  Created by JP Wright on 22.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = ViewController()

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}
