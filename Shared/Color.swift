//
//  Color.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit

public enum Color {
    case blue
    case red
    case purple
    case yellow
    
    public var uiColor: UIColor {
        switch self {
        case .blue:
            return #colorLiteral(red: 0.08006259054, green: 0.540450871, blue: 0.9225634933, alpha: 1)
        case .red:
            return #colorLiteral(red: 0.9960784314, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        case .purple:
            return #colorLiteral(red: 0.8470588235, green: 0.8196078431, blue: 0.9764705882, alpha: 1)
        case .yellow:
            return #colorLiteral(red: 0.9921568627, green: 0.9647058824, blue: 0.8980392157, alpha: 1)
        }
    }
}
