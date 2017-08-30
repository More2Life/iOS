//
//  HalfModalTransitioningDelegate.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/28/17.
//  Copyright © 2017 More2Life. All rights reserved.
//


import UIKit

class HalfModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var viewController: UIViewController
    var presentingViewController: UIViewController
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
		
        super.init()
    }
	
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
	
}

extension UIViewController { }
