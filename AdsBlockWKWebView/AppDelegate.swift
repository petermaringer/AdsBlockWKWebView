// AppDelegate.swift
// AdsBlockWKWebView
// Created by Wolfgang Weinmann on 2019/12/31.
// Copyright © 2019 Wolfgang Weinmann.

import UIKit

import Darwin
import os.log
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let test = OSLog(subsystem: subsystem, category: "Test")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var sesscat: String = "sesscat"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    /*
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
let documentsDirectory = paths[0]
let fileName = "\(Date()).log"
let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stdout)
    */
    if true /*isatty(STDERR_FILENO) != 1*/ { // if no terminal is attached to stderr
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logfileUrl = documentsUrl.appendingPathComponent("out.log")
            logfileUrl.withUnsafeFileSystemRepresentation { path in
                guard let path = path else {
                    return
                }
                print("redirect stderr and stderr to: \(String(cString: path))")
                let file = fopen(path, "a")
                assert(file != nil, String(cString: strerror(errno)))
                let fd = fileno(file)
                assert(fd >= 0, String(cString: strerror(errno)))
                let result1 = dup2(fd, STDERR_FILENO)
                assert(result1 >= 0, String(cString: strerror(errno)))
                let result2 = dup2(fd, STDOUT_FILENO)
                assert(result2 >= 0, String(cString: strerror(errno)))

                os_log("***** os_log: Test", log: OSLog.test, type: .debug)
                print("***** print:Test")
                NSLog("***** NSLog: Test")
            }
        }
        os_log("os_log: Test", log: OSLog.test, type: .debug)
        print("print: Test")
        NSLog("NSLog: Test")
    
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
