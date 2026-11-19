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

import UIKit

/// Utility class to download images asynchronously
class ImageDownloader {
    /// Download a single image from the provided URL.
    /// This method does not provide the error status. Use `downloadImages` for more control.
    ///
    /// - Parameters:
    ///   - url: The URL string for the image to be downloaded.
    ///   - completion: A completion block with the downloaded image or nil if the download failed.
    func downloadImage(url: String?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }

        downloadImages(urls: [url], completion: { downloadedImages in
            let result = downloadedImages[url]
            switch result {
            case let .success(image):
                completion(image)
            case let .failure(error):
                print("Image at url : \(url) failed to download. Reason: \(error.description)")
                completion(nil)
            case .none:
                print("Unexpected error. Downloading image from url :\(url)")
                completion(nil)
            }
        })
    }

    /// Downloads images from the provided URLs.
    /// - Parameters:
    ///   - urls: Array of string URLs for the images to be downloaded.
    ///   - completion: A  completion block with dictionary containing the result of each downloaded image
    func downloadImages(urls: [String], completion: @escaping ([String: Result<UIImage, ImageDownloadError>]) -> Void) {
        // Quick bail out if no URLs are provided
        if urls.isEmpty {
            completion([:])
        }

        // Create a dispatch group to track the download progress
        let downloadGroup = DispatchGroup()
        // URLSession completions run on background threads concurrently, so results are written under a lock to avoid a data race.
        let resultsLock = NSLock()
        nonisolated(unsafe) var downloadedImages: [String: Result<UIImage, ImageDownloadError>] = [:]

        // Download images concurrently
        for urlString in urls {
            downloadGroup.enter()
            loadImageFromURL(urlString) { result in
                resultsLock.lock()
                downloadedImages[urlString] = result
                resultsLock.unlock()
                downloadGroup.leave()
            }
        }

        // Completion is only called on the main queue after every download finished, so it is safe to hand it to the notify block.
        nonisolated(unsafe) let completion = completion
        // Notify the main queue when all downloads are complete
        downloadGroup.notify(queue: .main) {
            resultsLock.lock()
            let results = downloadedImages
            resultsLock.unlock()
            completion(results)
        }
    }

    /// Downloads a single image from the given URL.
    ///
    /// - Parameters:
    ///   - urlString: The URL string for the image to be downloaded.
    ///   - completion: A `Result` value called with the downloaded image or an ImageDownloadError.
    // The completion is Sendable because URLSession calls it on a background queue. This is an internal API so no public signature changes.
    private func loadImageFromURL(_ urlString: String, completion: @escaping @Sendable (Result<UIImage, ImageDownloadError>) -> Void) {
        // validate the url before downloading
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL(url: urlString)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            // check for network error
            if let error = error {
                completion(.failure(.networkError(url: url.absoluteString, error: error)))
                return
            }

            // convert the data into image
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidImageData(url: url.absoluteString)))
                return
            }

            // on successful download call the completion with success
            completion(.success(image))
        }.resume()
    }
}
