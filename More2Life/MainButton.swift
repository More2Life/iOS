//
//  MainButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit
import Shared


@IBDesignable class MainButton: UIButton {
	
	@IBInspectable var startColor: UIColor = Color.blueDark.uiColor {
		didSet{
			setupView()
		}
	}
 
	@IBInspectable var endColor:  UIColor = Color.blueLight.uiColor {
		didSet{
			setupView()
		}
	}
 
	@IBInspectable var cornerRadius: CGFloat = 10.0 {
		didSet{
			setupView()
		}
	}
	
	private func setupView(){
		
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
	
	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
	override func awakeFromNib() {
		setupView()
	}
}
