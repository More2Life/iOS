//
//  MainButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class MainButton: UIButton {
	
	@IBInspectable var startColor: UIColor = Color.darkBlue.uiColor {
		didSet{
			setupView()
		}
	}
 
	@IBInspectable var endColor:  UIColor = Color.lightBlue.uiColor {
		didSet{
			setupView()
		}
	}
	
	private func setupView() {
		
		let colors:Array = [startColor.cgColor, endColor.cgColor]
		gradientLayer.colors = colors
		gradientLayer.cornerRadius = cornerRadius
		gradientLayer.startPoint = CGPoint(x: 0, y: 1)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0)
		
		self.setNeedsDisplay()
		
	}
	
	var gradientLayer: CAGradientLayer {
		return layer as! CAGradientLayer
	}
	
	override public class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
	override public func awakeFromNib() {
        super.awakeFromNib()
		setupView()
	}
}
