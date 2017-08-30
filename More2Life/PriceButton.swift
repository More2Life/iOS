//
//  PriceButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit

class PriceButton: UIButton {
	
	override func awakeFromNib() {
		layer.cornerRadius = 10
		layer.borderWidth = 2
		layer.borderColor = (UIColor.red).cgColor as CGColor
		self.setTitleColor(UIColor.red, for: .normal)
	}
}
