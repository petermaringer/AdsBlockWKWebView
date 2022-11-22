platform :ios, '10.0'
#use_frameworks!

#pod "GCDWebServer", "~> 3.0"

target 'AdsBlockWKWebView' do
  use_frameworks!
  pod 'GCDWebServer', '~> 3.0'
  pod 'OpenSSL-iOS', '~> 1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
