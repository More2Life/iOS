//
//  FirstViewController.swift
//  More2Life
//
//  Created by Porter Hoskins on 7/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Shared
import CoreData

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FeedItem.import(in: Shared.viewContext) { _ in
            let fetchRequest: NSFetchRequest<FeedItem> = FeedItem.fetchRequest()
            
            print(try! Shared.viewContext.fetch(fetchRequest))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

