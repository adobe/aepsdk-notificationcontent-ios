source 'https://cdn.cocoapods.org/'

platform :ios, '15.0'

use_frameworks!

# don't warn me
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

workspace 'AEPNotificationContent'
project 'AEPNotificationContent.xcodeproj'

pod 'SwiftLint', '0.52.0'

def app_main
    pod 'AEPCore'
    pod 'AEPServices'
    pod 'AEPLifecycle'
    pod 'AEPRulesEngine'
    pod 'AEPSignal'
    pod 'AEPEdge'
    pod 'AEPEdgeIdentity'
    pod 'AEPEdgeConsent'
    pod 'AEPAssurance'
    pod 'AEPMessaging'
end

def dev_main
    pod 'AEPCore'
    pod 'AEPServices'
    pod 'AEPLifecycle'
    pod 'AEPRulesEngine'
    pod 'AEPSignal'
    pod 'AEPEdge'
    pod 'AEPEdgeIdentity'
    pod 'AEPEdgeConsent'
    pod 'AEPAssurance'
end

target 'DemoApp' do
    app_main
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
      bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
