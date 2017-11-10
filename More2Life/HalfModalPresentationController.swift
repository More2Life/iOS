//
//  HalfModalPresentationController.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/28/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit

class HalfModalPresentationController : UIPresentationController {
	
    var _dimmingView: UIView?
    var dimmingView: UIView {
        if let dimmedView = _dimmingView {
            return dimmedView
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        
        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissOnTap))
		view.addGestureRecognizer(gestureRecognizer)
		
        _dimmingView = view
		
        return view
    }
	
	@objc func dismissOnTap(sender: UITapGestureRecognizer) {
		presentingViewController.dismiss(animated: true, completion: nil)
	}
 
    override var frameOfPresentedViewInContainerView: CGRect {
		guard let containerView = containerView else {
			fatalError("If we don't have a container view here there is no point to the entire app. It's coming from the storyboard.")
		}
		return CGRect(x: 0, y: containerView.bounds.height * 0.333 , width: containerView.bounds.width, height: containerView.bounds.height * 0.666)
		
	}
	
	override func containerViewWillLayoutSubviews() {
		presentedView?.frame = frameOfPresentedViewInContainerView
	}
    
    override func presentationTransitionWillBegin() {
        let dimmedView = dimmingView
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
			
            containerView.addSubview(dimmedView)
            dimmedView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
		let dimmedView = dimmingView
		guard let containerView = containerView else {
			fatalError("If we don't have a container view here there is no point to the entire app. It's coming from the storyboard.")
		}
		let height = containerView.frame.height
		
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
				dimmedView.alpha = 0
				self.presentingViewController.view.transform = CGAffineTransform.identity
//				containerView.frame.origin.y = height
            }, completion: nil)
            
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
		guard let containerView = containerView else {
			fatalError("If we don't have a container view here there is no point to the entire app. It's coming from the storyboard.")
		}
		
        if completed {
            dimmingView.removeFromSuperview()
            _dimmingView = nil
		} else {
			dimmingView.alpha = 1
			self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
			containerView.frame.origin.y = 0
		}
	}
}
