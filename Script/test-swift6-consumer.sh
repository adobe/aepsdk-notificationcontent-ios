#!/bin/bash
#
# Copyright 2026 Adobe. All rights reserved.
# This file is licensed to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
# OF ANY KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

# Builds a throwaway Swift 6 consumer that subclasses AEPNotificationViewController from a notification content extension,
# overrides its open members and calls the UNNotificationContentExtension methods from main actor code.
PROJECT_NAME=Swift6Consumer

rm -rf $PROJECT_NAME
mkdir -p $PROJECT_NAME/Sources/$PROJECT_NAME && cd $PROJECT_NAME

echo "// swift-tools-version:6.0
import PackageDescription
let package = Package(
    name: \"$PROJECT_NAME\",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: \"$PROJECT_NAME\", targets: [\"$PROJECT_NAME\"])
    ],
    dependencies: [
        .package(name: \"AEPNotificationContent\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"$PROJECT_NAME\",
            dependencies: [
                .product(name: \"AEPNotificationContent\", package: \"AEPNotificationContent\")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
" >Package.swift

cat >Sources/$PROJECT_NAME/Swift6Consumer.swift <<'SWIFT'
import AEPNotificationContent
import UIKit
import UserNotifications
import UserNotificationsUI

final class NotificationViewController: AEPNotificationViewController {
    var lastClickURL: String?

    override func handleNotificationClickURL(_ urlString: String?) {
        lastClickURL = urlString
        super.handleNotificationClickURL(urlString)
    }
}

@MainActor
final class Swift6Consumer {
    let controller = NotificationViewController()

    func exercise(_ notification: UNNotification, _ response: UNNotificationResponse) {
        controller.didReceive(notification)
        controller.didReceive(response) { option in
            let raw = option.rawValue
            Task { @MainActor in _ = raw }
        }
        let content: UNNotificationContentExtension = controller
        content.didReceive(notification)
    }
}
SWIFT

swift package update

echo '############# Build Swift 6 consumer for generic iOS device ###############'
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS'

cd ..
rm -rf $PROJECT_NAME
