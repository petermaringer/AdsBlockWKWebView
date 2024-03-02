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
        // self.extensionContext can be used to retrieve images, videos and urls from share extension input
        let extensionAttachments = (self.extensionContext!.inputItems.first as! NSExtensionItem).attachments
        //for provider in extensionAttachments! {
        for case let provider as NSItemProvider in extensionAttachments! {
            // loadItem can be used to extract different types of data from NSProvider object in attachements
            provider.loadItem(forTypeIdentifier: "public.image"){ data, _ in
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
                            //self.addChild(u)
                            self.addChildViewController(u)
                        }
                        // [END]
                    }
                }
            }
        }
    }
}

