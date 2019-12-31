//
// ViewController.swift
// AdsBlockWKWebView
//
// Created by Wolfgang Weinmann on 2019/12/31.
// Copyright © 2019 Wolfgang Weinmann.
//

import UIKit
import WebKit

fileprivate let ruleId1 = "MyRuleID 001"
fileprivate let ruleId2 = "MyRuleID 002"

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webview: WKWebView!
    
    override func viewSafeAreaInsetsDidChange() {
        var insetT: CGFloat = 0
        var insetB: CGFloat = 0
        if #available(iOS 11.0, *) {
        insetT = self.view.safeAreaInsets.top
        insetB = self.view.safeAreaInsets.bottom
        }
        webview.frame.size.height = self.view.frame.height - insetT - insetB
        
        //let popup = UIView(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
        let lb = UILabel(frame: CGRect(x: 100, y: 200, width: 200, height: 100))
        lb.text = "log: \(insetT) \(insetB)"
        lb.textAlignment = .center
        lb.backgroundColor = .red
        self.view.addSubview(lb)
        //popup.addSubview(lb)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        
        UserDefaults.standard.register(defaults: [
            ruleId1 : false,
            ruleId2 : false
            ])
        UserDefaults.standard.synchronize()
        
        webview = WKWebView(frame: CGRect.zero)
        //webview = WKWebView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height - 200))
        
        //var wvins = self.view.frame.height
        //var wvheight = self.view.frame.height
        //if #available(iOS 11.0, *) {
        //let guide = self.view.safeAreaLayoutGuide
        //wvheight = guide.layoutFrame.size.height
        //wvins = self.view.safeAreaInsets.top
        //}
        
        //webview = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: wvheight))

        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        view.addSubview(webview)
        webview.frame = view.bounds
        
        if #available(iOS 11, *) {
            let group = DispatchGroup()
            group.enter()
            setupContentBlockFromStringLiteral {
                group.leave()
            }
            group.enter()
            setupContentBlockFromFile {
                group.leave()
            }
            group.notify(queue: .main, execute: { [weak self] in
                self?.startLoading()
            })
        } else {
            alertToUseIOS11()
            startLoading()
        }
    }
    
    private func startLoading() {
        let url = URL(string: "https://www.google.com")!
        let request = URLRequest(url: url)
        webview.load(request)
    }
    
    
    @available(iOS 11.0, *)
    private func setupContentBlockFromStringLiteral(_ completion: (() -> Void)?) {
        // Swift 4  Multi-line string literals
        let jsonString = """
[{
  "trigger": {
    "url-filter": "://googleads\\\\.g\\\\.doubleclick\\\\.net.*"
  },
  "action": {
    "type": "block"
  }
}]
"""
        if UserDefaults.standard.bool(forKey: ruleId1) {
            // list should already be compiled
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: ruleId1) { [weak self] (contentRuleList, error) in
                if let error = error {
                    self?.printRuleListError(error, text: "lookup json string literal")
                    UserDefaults.standard.set(false, forKey: ruleId1)
                    self?.setupContentBlockFromStringLiteral(completion)
                    return
                }
                if let list = contentRuleList {
                    self?.webview.configuration.userContentController.add(list)
                    completion?()
                }
            }
        }
        else {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: ruleId1, encodedContentRuleList: jsonString) { [weak self] (contentRuleList: WKContentRuleList?, error: Error?) in
                if let error = error {
                    self?.printRuleListError(error, text: "compile json string literal")
                    return
                }
                if let list = contentRuleList {
                    self?.webview.configuration.userContentController.add(list)
                    UserDefaults.standard.set(true, forKey: ruleId1)
                    completion?()
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    private func setupContentBlockFromFile(_ completion: (() -> Void)?) {
        if UserDefaults.standard.bool(forKey: ruleId2) {
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: ruleId2) { [weak self] (contentRuleList, error) in
                if let error = error {
                    self?.printRuleListError(error, text: "lookup json file")
                    UserDefaults.standard.set(false, forKey: ruleId2)
                    self?.setupContentBlockFromFile(completion)
                    return
                }
                if let list = contentRuleList {
                    self?.webview.configuration.userContentController.add(list)
                    completion?()
                }
            }
        }
        else {
            if let jsonFilePath = Bundle.main.path(forResource: "adaway.json", ofType: nil),
                let jsonFileContent = try? String(contentsOfFile: jsonFilePath, encoding: String.Encoding.utf8) {
                WKContentRuleListStore.default().compileContentRuleList(forIdentifier: ruleId2, encodedContentRuleList: jsonFileContent) { [weak self] (contentRuleList, error) in
                    if let error = error {
                        self?.printRuleListError(error, text: "compile json file")
                        return
                    }
                    if let list = contentRuleList {
                        self?.webview.configuration.userContentController.add(list)
                        UserDefaults.standard.set(true, forKey: ruleId2)
                        completion?()
                    }
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    private func resetContentRuleList() {
        let config = webview.configuration
        config.userContentController.removeAllContentRuleLists()
    }
    
    private func alertToUseIOS11() {
        let title: String? = "Use iOS 11 and above for ads-blocking."
        let message: String? = nil
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        DispatchQueue.main.async { [unowned self] in
            self.view.window?.rootViewController?.present(alertController, animated: true, completion: {
                
            })
        }
    }
    
    
    @available(iOS 11.0, *)
    private func printRuleListError(_ error: Error, text: String = "") {
        guard let wkerror = error as? WKError else {
            print("\(text) \(type(of: self)) \(#function): \(error)")
            return
        }
        switch wkerror.code {
        case WKError.contentRuleListStoreLookUpFailed:
            print("\(text) WKError.contentRuleListStoreLookUpFailed: \(wkerror)")
        case WKError.contentRuleListStoreCompileFailed:
            print("\(text) WKError.contentRuleListStoreCompileFailed: \(wkerror)")
        case WKError.contentRuleListStoreRemoveFailed:
            print("\(text) WKError.contentRuleListStoreRemoveFailed: \(wkerror)")
        case WKError.contentRuleListStoreVersionMismatch:
            print("\(text) WKError.contentRuleListStoreVersionMismatch: \(wkerror)")
        default:
            print("\(text) other WKError \(type(of: self)) \(#function):\(wkerror) \(wkerror)")
            break
        }
    }
    
    // Just for invalidating target="_blank"
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
    

}

