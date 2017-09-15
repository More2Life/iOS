//
//  ImagePageViewController.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/15/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit

class ImagePageViewController: UIPageViewController {

    var imageURLs: [URL] = []
    
    var imageViewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        let appearance = UIPageControl.appearance()
        appearance.currentPageIndicatorTintColor = .darkGray
        appearance.pageIndicatorTintColor = #colorLiteral(red: 0.878935039, green: 0.878935039, blue: 0.878935039, alpha: 1)
        
        var viewControllers: [UIViewController] = []
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        for url in imageURLs {
            let imageViewController: ImageViewController = storyboard.instantiateViewController()
            imageViewController.url = url
            
            viewControllers.append(imageViewController)
        }
        
        imageViewControllers = viewControllers
        setViewControllers([viewControllers.first ?? UIViewController()], direction: .forward, animated: false, completion: nil)
    }
}

extension ImagePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
        guard let index = imageViewControllers.index(of: viewController), index - 1 >= 0 else { return nil }
        return imageViewControllers[imageViewControllers.index(before: index)]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
        guard let index = imageViewControllers.index(of: viewController), index + 1 < imageViewControllers.count else { return nil }
        return imageViewControllers[imageViewControllers.index(after: index)]
    }
    
    // MARK: - Page Indicator
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imageViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController)-> Int {
        return 0
    }
}
