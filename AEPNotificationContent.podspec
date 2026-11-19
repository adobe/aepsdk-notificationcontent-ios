Pod::Spec.new do |s|
  s.name         = "AEPNotificationContent"
  s.version      = "5.0.2"
  s.summary      = "AEPNotificationContent extension for Adobe Experience Cloud SDK. Written and maintained by Adobe."
  s.description  = <<-DESC
                   The AEPNotificationContent extension is used in conjunction with AEPMessaging or AEPCampaignClassic to deliver push notification with predefined templates.
                   DESC

  s.homepage     = "https://github.com/adobe/aepsdk-notificationcontent-ios.git"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = "Adobe Experience Platform SDK Team"
  s.source       = { :git => 'https://github.com/adobe/aepsdk-notificationcontent-ios.git', :tag => s.version.to_s }
  
  s.platform = :ios, "15.0"
  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.source_files = 'AEPNotificationContent/Sources/**/*.swift'

end
