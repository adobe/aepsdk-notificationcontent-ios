/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import UIKit

// Every template controller calls this delegate from UIKit code on the main thread. Marking it main actor lets AEPNotificationViewController conform in Swift 6.
@MainActor
protocol TemplateControllerDelegate {
    /// This method should be called when the template failed to load
    /// A template can fail if there are issues in downloading images, parsing the payload, etc.
    func templateFailedToLoad()

    /// Use this method to get the instance of the parent view controller
    func getParentViewController() -> UIViewController

    /// Use this method to handle the clickURL from interactions with the push template
    func handleNotificationClickURL(_ url: String?)
}
