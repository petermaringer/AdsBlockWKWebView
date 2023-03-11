// AppDelegate.swift
// AdsBlockWKWebView
// Created by Wolfgang Weinmann on 2019/12/31.
// Copyright © 2019 Wolfgang Weinmann.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var sesscat: String = "sesscat"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
let documentsDirectory = paths[0]
let fileName = "\(Date()).log"
let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stdout)
    
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    if let window = self.window {
      let viewController = ViewController()
      window.rootViewController = viewController
      window.backgroundColor = UIColor.white
      window.makeKeyAndVisible()
    }
    return true
  }
  
}
