//
//  PriceButton.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class PriceButton: UIButton {
	
	private func setupView() {
		layer.borderWidth = 2
		layer.borderColor = borderColor?.cgColor ?? UIColor.lightGray.cgColor
		setTitleColor(UIColor .white, for: .normal)
		layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        
		setNeedsDisplay()
	}

	
	override public func awakeFromNib() {
        super.awakeFromNib()
        
        cornerRadius = 10
		setupView()
	}
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
}
