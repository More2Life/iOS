//
//  StoryboardExtension.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/4/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation

extension UIStoryboard {
    
    public func instantiateViewController<T: UIViewController>() -> T {
        let viewController = self.instantiateViewController(withIdentifier: T.className)
        guard let typedViewController = viewController as? T else {
            fatalError("Unable to cast view controller of type (\(type(of: viewController))) to (\(T.className))")
        }
        return typedViewController
    }
}

extension NSObject {
    
    static var className: String {
        return String(describing: self)
    }
}
