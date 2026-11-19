//
// Copyright 2024 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation
import UIKit
import AEPAssurance
import AEPCore
import AEPEdge
import AEPEdgeConsent
import AEPEdgeIdentity
import AEPLifecycle
import AEPRulesEngine
import AEPSignal
import AEPMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MobileCore.setLogLevel(.debug)

        let extensions = [
            Lifecycle.self,
            Identity.self,
            AEPEdgeIdentity.Identity.self,
            Edge.self,
            Signal.self,
            Messaging.self,
            Assurance.self
        ]
        MobileCore.registerExtensions(extensions) {
            // only start lifecycle if the application is not in the background
            DispatchQueue.main.async {
                if application.applicationState != .background {
                    MobileCore.lifecycleStart(additionalContextData: nil)
                }
            }
            // configure
            MobileCore.configureWith(appId: "")
            #if DEBUG
                let debugConfig = ["messaging.useSandbox": true]
                MobileCore.updateConfigurationWith(configDict: debugConfig)
            #endif
        }

        registerForPushNotifications(application)
        return true
    }

    // MARK: - Push Notification registration methods
    func registerForPushNotifications(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        // Ask for user permission
        center.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] granted, _ in
            guard granted else { return }
            // The authorization callback runs on a background queue, so the delegate and categories are set up on main.
            DispatchQueue.main.async {
                let center = UNUserNotificationCenter.current()
                center.delegate = self
                self?.registerNotificationCategories()
                application.registerForRemoteNotifications()
            }
        }
    }

    func registerNotificationCategories() {
        // Define category with actions
        let myCategory = UNNotificationCategory(identifier: "AEPNotificationContentCategory", actions: [], intentIdentifiers: [], options: [.customDismissAction])

        // Register the all the category at once
        UNUserNotificationCenter.current().setNotificationCategories([myCategory])
    }

    // MARK: - Push Notification delegates
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MobileCore.setPushIdentifier(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.banner, .sound, .badge, .list])
    }

}

// UNUserNotificationCenterDelegate is not annotated for concurrency, but the system calls it on the main thread.
// A preconcurrency conformance lets this main actor app delegate conform in Swift 6.
#if swift(>=6.0)
    extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {}
#else
    extension AppDelegate: UNUserNotificationCenterDelegate {}
#endif
