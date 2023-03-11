// AppDelegate.swift
// AdsBlockWKWebView
// Created by Wolfgang Weinmann on 2019/12/31.
// Copyright © 2019 Wolfgang Weinmann.

import UIKit

//BackgroundAudioBegin
//import AVFoundation
//import AVKit
//BackgroundAudioEnd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var sesscat: String = "sesscat"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    if let window = self.window {
      let viewController = ViewController()
      window.rootViewController = viewController
      window.backgroundColor = UIColor.white
      window.makeKeyAndVisible()
    }
    return true
  }
  
    ///func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    ///}

    ///func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    ///}

}
