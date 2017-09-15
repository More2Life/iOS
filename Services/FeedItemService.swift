//
//  FeedItemService.swift
//  More2Life
//
//  Created by Porter Hoskins on 7/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import Alamofire

//#if DEBUG
    let host = "m2l-server-dev.herokuapp.com"
//#else
//    let host = "m2l-server.herokuapp.com"
//#endif

public final class FeedItemService {
    
    public static func `import`(completion: @escaping (_ json: [[String : Any]]?)->()) {
        Alamofire.request("https://\(host)/api/feedItems?isActive=true").responseJSON { response in
            completion(response.result.value as? [[String : Any]])
        }
    }
    
}
