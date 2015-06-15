//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = representedObject as? Tree else {
            return
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
            guard let tree = representedObject as? Tree else {
                representedObject = nil
                return
            }
            if let p = tree.getPerson(givenName: "Ezekiel", familyName: "Elin") {
                print(p.allSiblings)
                print(p.fullSiblings)
            } else {
                print("Couldn't find...")
            }
        }
    }
}

