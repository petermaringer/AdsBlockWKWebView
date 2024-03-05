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
  
  /*
  override func viewDidLoad() {
    super.viewDidLoad()
    let extensionAttachments = (self.extensionContext!.inputItems.first as! NSExtensionItem).attachments
    for provider in extensionAttachments! {
      handleIncomingImage(itemProvider: provider)
      //
      provider.loadItem(forTypeIdentifier: "public.image") { data, _ in
        if let url = data as? URL {
          if let imageData = try? Data(contentsOf: url) {
            let uiimg = UIImage(data: imageData)!
            let image = Image(uiImage: uiimg)
            DispatchQueue.main.async {
              let u = UIHostingController(rootView: ImageView(image: image))
              u.view.frame = (self.view.bounds)
              self.view.addSubview(u.view)
              self.addChild(u)
            }
          }
        }
      }
      //
    }
  }
  */
  
  var incomingItemType: String = "Undefined"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  //override func viewDidAppear(_ animated: Bool) {
    //super.viewDidAppear(animated)
    guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionItem.attachments?.first else {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
      return
    }
    if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
      handleIncomingImage(itemProvider: itemProvider)
      return
    } else if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
      handleIncomingURL(itemProvider: itemProvider)
    } else {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if incomingItemType != "Image" {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
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
            incomingItemType = "Image"
          }
        }
      }
    }
  }
  
  private func handleIncomingURL(itemProvider: NSItemProvider) {
    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (item, error) in
      if let error = error {
        print("URL-Error: \(error.localizedDescription)")
      }
      if let url = item as? NSURL, let urlString = url.absoluteString {
        print(urlString)
        UserDefaults(suiteName: "group.at.co.weinmann.AdsBlockWKWebView")?.set(urlString, forKey: "incomingURL")
        incomingItemType = "Url"
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
          guard let url = URL(string: "adsblockwkwebview://") else { return }
          _ = self.openURL(url)
        })
        return
      }
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
