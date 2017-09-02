//
//  PriceButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PriceButton: UIButton {
	

 
	@IBInspectable var cornerRadius: CGFloat = 10.0 {
		didSet{
			setupView()
		}
	}
	
	private func setupView(){
		
		layer.cornerRadius = cornerRadius
		layer.borderWidth = 2
		layer.borderColor = (UIColor.red).cgColor as CGColor
		self.setTitleColor(UIColor.red, for: .normal)
		
		self.setNeedsDisplay()
		
	}

	
	override func awakeFromNib() {
		setupView()
	}
}
