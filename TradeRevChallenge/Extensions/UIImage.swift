//
//  UIImageView.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

fileprivate var imagesCache = NSCache<NSString, UIImage>()

extension UIImage {

    static func downloaded(from url: URL, completion: @escaping (Result<UIImage, DataResponseError>) -> Void) {
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) {
            completion(Result.success(cachedImage))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(Result.failure(.network))
                    return
            }
            imagesCache.setObject(image, forKey: url.absoluteString as NSString)
            completion(Result.success(image))
            }.resume()
    }

}
