//
//  CircleView.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit

@IBDesignable
public class CircleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        cornerRadius = frame.height / 2
    }
}
