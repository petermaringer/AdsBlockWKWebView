#platform :ios, '10.0'
platform :ios, '15.0'

#use_frameworks!
#pod "GCDWebServer", "~> 3.0"

target 'AdsBlockWKWebView' do
  use_frameworks!
  #pod 'GCDWebServer', '~> 3.0'
  #pod 'Telegraph'
  pod 'Telegraph', '~> 0.15'
  pod 'CocoaAsyncSocket', '~> 7.6.5'
  
  pod 'OpenSSL-Universal', '~> 1.1'
  pod 'CertificateSigningRequest', '~> 1.27'
  #pod 'SwCrypt', '~> 5.1'
  #pod 'openssl-apple-platform', '1.0.2r'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      #config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
