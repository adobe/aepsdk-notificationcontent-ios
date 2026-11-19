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
import XCTest

// XCUIApplication is main actor only in Swift 6. UI tests drive the app from the main thread, so the base test case runs on the main actor.
@MainActor
class AEPXCTestCase : XCTestCase {
    
    //  Constants for test notification
    let APS_NOTIFICATION_TITLE = "Notification Title"
    let APS_NOTIFICATION_BODY = "Notification Body"
    let EXPANDED_TITLE = "Expanded Title"
    let EXPANDED_BODY = "Expanded Body"
    
    let app = XCUIApplication()
    
    // Demo App UI Elements
    var userInfoTextField : XCUIElement?
    var triggerNotificationBtn : XCUIElement?
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        // Request notification permission
        addUIInterruptionMonitor(withDescription: "Notification permissions") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
    }
    
    override func tearDownWithError() throws {
        userInfoTextField?.typeText("")
    }
    
    // Helper methods
    func triggerAndOpenNotification(_ payload: String) {
        setNotificationUserInfo(payload)
        triggerNotification()
        sleep(2)
        longPressNotification()
    }
    
    func getNotificationBanner() -> XCUIElement {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        return springboard.otherElements["notification-expanded-view"].firstMatch
    }
    
    func verifyFallbackTemplateShown() {
        let notificationBanner = getNotificationBanner()
        let title = notificationBanner.staticTexts["AEPNotificationContentTitle"]
        let description = notificationBanner.staticTexts["AEPNotificationContentDescription"]
        
        XCTAssert(title.waitForExistence(timeout: 7))
        XCTAssert(description.exists)
        
        XCTAssertEqual(title.label, APS_NOTIFICATION_TITLE)
        XCTAssertEqual(description.label, APS_NOTIFICATION_BODY)
    }
    
    // Private methods
    private func setNotificationUserInfo(_ payload : String) {
        userInfoTextField = app.textViews["txtUserinfo"]
        userInfoTextField?.tap()
        userInfoTextField?.typeText(payload)
    }
    
    private func triggerNotification() {
        triggerNotificationBtn = app.buttons["btnNotification"]
        triggerNotificationBtn?.tap()
    }

    private func longPressNotification(){
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let notificationArea = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        notificationArea.press(forDuration: 1.0)
    }
}

