//
//  FeedItemService.swift
//  More2Life
//
//  Created by Porter Hoskins on 7/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import Alamofire

public final class FeedItemService {
    
    public static func `import`(completion: @escaping (_ json: [[String : Any]]?)->() = { _ in }) {
        Alamofire.request("https://m2l-server.herokuapp.com/api/feedItems").responseJSON { response in
            completion(response.result.value as? [[String : Any]])
        }
    }
    
}
