//
//  UIImageExtension.swift
//  Shared
//
//  Created by Porter Hoskins on 9/15/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import Alamofire

let imageCache = NSCache<NSString, UIImage>()

public extension UIImage {
    
    @discardableResult
    static func fetch(with urlString: String, completion: @escaping (_ image: UIImage?, _ request: URLRequest?) -> ()) -> DataRequest? {
        return Alamofire.request(urlString as String).validate(contentType: ["image/*"]).response { response in
            var image: UIImage?
            defer {
                completion(image, response.request)
            }
            
            guard response.error == nil, let data = response.data, let previewImage = UIImage(data: data) else {
                /*
                 If the cell went off-screen before the image was downloaded, we cancel it and
                 an NSURLErrorDomain (-999: cancelled) is returned. This is a normal behavior.
                 */
                if let error = response.error {
                    print("Error fetching image in feed cell \(error) for \(urlString)")
                }
                return
            }
            
            image = previewImage
            
            imageCache.setObject(previewImage, forKey: urlString as NSString)
        }
    }
}
