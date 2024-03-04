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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let extensionAttachments = (self.extensionContext!.inputItems.first as! NSExtensionItem).attachments
    for provider in extensionAttachments! {
      provider.loadItem(forTypeIdentifier: "public.image") { data, _ in
        
                // Load Image data from image URL
                if let url = data as? URL {
                    if let imageData = try? Data(contentsOf: url) {
                        // Load Image as UIImage from image data
                        let uiimg = UIImage(data: imageData)!
                        // Convert to SwiftUI Image
                        let image = Image(uiImage: uiimg)
                        // [START] The following piece of code can be used to render swifUI views from UIKit
                        DispatchQueue.main.async {
                            let u = UIHostingController(
                                rootView: ImageView(image: image)
                            )
                            u.view.frame = (self.view.bounds)
                            self.view.addSubview(u.view)
                            self.addChild(u)
                            //self.addChildViewController(u)
                        }
                        // [END]
                    }
                }
      
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionItem.attachments?.first else {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
      return
    }
    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
      handleIncomingURL(itemProvider: itemProvider)
    } else if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
      return
    } else {
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
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
      }
      self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
  }
  
}
