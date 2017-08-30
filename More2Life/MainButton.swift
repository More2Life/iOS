//
//  MainButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit

class MainButton: UIButton {
	
	override func awakeFromNib() {
		layer.cornerRadius = 10
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		addGradientBackgroundLayer()
	}
	
	// MARK: Private
	private func addGradientBackgroundLayer() {
		let gradientLayer = CAGradientLayer()
		let color1 = UIColor(red:13/255, green:76/255, blue:146/255, alpha: 1.0).cgColor as CGColor
		let color2 = UIColor(red:52/255, green:110/255, blue:234/255, alpha: 1.0).cgColor as CGColor
		gradientLayer.colors = [color1, color2]
		gradientLayer.startPoint = CGPoint(x: 0, y: 1)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0)
		gradientLayer.frame = layer.bounds
		gradientLayer.cornerRadius = 10
		layer.insertSublayer(gradientLayer, at: 0)
	}
}
