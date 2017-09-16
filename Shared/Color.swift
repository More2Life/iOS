//
//  Color.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit

public enum Color {
	case darkRed
    case lightRed
	case darkPurple
    case lightPurple
	case darkGreen
    case lightGreen
	case darkBlue
	case lightBlue
    
    public var uiColor: UIColor {
        switch self {
		case .darkRed:
			return #colorLiteral(red: 0.9490196078, green: 0.2039215686, blue: 0.2078431373, alpha: 1)
        case .lightRed:
            return #colorLiteral(red: 0.9960784314, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
		case .darkPurple:
			return #colorLiteral(red: 0.4156862745, green: 0.2901960784, blue: 0.9568627451, alpha: 1)
        case .lightPurple:
            return #colorLiteral(red: 0.8470588235, green: 0.8196078431, blue: 0.9764705882, alpha: 1)
		case .darkGreen:
			return #colorLiteral(red: 0.1254901961, green: 0.6078431373, blue: 0.02352941176, alpha: 1)
        case .lightGreen:
            return #colorLiteral(red: 0.9019607843, green: 0.9921568627, blue: 0.8980392157, alpha: 1)
		case .darkBlue:
			return #colorLiteral(red: 0.05098039216, green: 0.2980392157, blue: 0.5725490196, alpha: 1)
		case .lightBlue:
			return #colorLiteral(red: 0.2039215686, green: 0.431372549, blue: 0.9176470588, alpha: 1)
        }
    }
}
