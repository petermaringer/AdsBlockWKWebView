import UIKit
import SwiftUI

struct ImageView: View {
  @State var image: Image
  var body: some View {
    VStack {
      Spacer()
      Text("👋 Hello, from share extension").font(.largeTitle)
      image.resizable().aspectRatio(contentMode: .fit)
      Spacer()
    }
  }
}

@objc(ShareViewController)
class ShareViewController: UIViewController {
  
  var incomingItemType: String = "Undefined"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionItem.attachments?.first else { return }
    
    for extItem in extensionContext!.inputItems as! [NSExtensionItem] {
      if let extAttachments = extItem.attachments {
        for itemProvider in extAttachments {
    
    if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
      handleIncomingImage(itemProvider: itemProvider)
      return
    }
    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
      handleIncomingUrl(itemProvider: itemProvider)
      return
    }
    
    } } }
    
  }
  
  private func handleIncomingImage(itemProvider: NSItemProvider) {
    itemProvider.loadItem(forTypeIdentifier: "public.image", options: nil) { (item, error) in
      if let url = item as? URL {
        if let imageData = try? Data(contentsOf: url) {
          let uiimg = UIImage(data: imageData)!
          let image = Image(uiImage: uiimg)
          DispatchQueue.main.async {
            let u = UIHostingController(rootView: ImageView(image: image))
            u.view.frame = (self.view.bounds)
            self.view.addSubview(u.view)
            self.addChild(u)
            self.incomingItemType = "Image"
          }
        }
      }
    }
  }
  
  private func handleIncomingUrl(itemProvider: NSItemProvider) {
    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (item, error) in
      if let url = item as? NSURL, let urlString = url.absoluteString {
        UserDefaults(suiteName: "group.at.co.weinmann.AdsBlockWKWebView")?.set(urlString, forKey: "incomingURL")
        self.incomingItemType = "Url"
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    //override func viewWillAppear(_ animated: Bool) {
    //super.viewWillAppear(animated)
    
    if incomingItemType == "Url" {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
        guard let url = URL(string: "adsblockwkwebview://") else { return }
        _ = self.openURL(url)
      })
    }
    if incomingItemType == "Undefined" {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
  }
  
  @objc private func openURL(_ url: URL) -> Bool {
    var responder: UIResponder? = self
    while responder != nil {
      if let application = responder as? UIApplication {
        return application.perform(#selector(openURL(_:)), with: url) != nil
      }
      responder = responder?.next
    }
    return false
  }
  
}
