//
//  AppDelegate.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 01/13/2017.
//  Copyright (c) 2019 Sixt SE. All rights reserved.
//

import UIKit
import Swen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Swen.post(UIEvents.ColorChanged(color))

        return true
    }
}
