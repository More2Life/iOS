//
//  ImageViewController.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/15/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Shared

class ImageViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView?
    
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Preview image
        if let imageURL = url?.absoluteString {
            UIImage.fetch(with: imageURL) { [weak self] image, request in
                if Thread.isMainThread {
                    self?.previewImageView?.image = image
                } else {
                    DispatchQueue.main.async {
                        self?.previewImageView?.image = image
                    }
                }
            }
        }
    }

}
