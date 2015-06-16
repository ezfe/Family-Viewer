//
//  AddParentViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/15/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class AddParentViewController: NSViewController {

    @IBOutlet weak var popupChooser: NSPopUpButton!
    var parentTo: Person? = nil
    var A_B: String = "A"
    var tree: Tree = Tree()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.popupChooser.addItemsWithTitles(tree.indexOfPeople)
    }

    @IBAction func setParent(sender: AnyObject) {
        guard let parentTo = parentTo else {
            return
        }
        if self.popupChooser.indexOfSelectedItem == 0 {
            return
        }
        let parent = self.tree.people[self.popupChooser.indexOfSelectedItem - 1]
        if self.A_B == "A" {
            parentTo.parentA = parent
        } else if self.A_B == "B" {
            parentTo.parentB = parent
        }
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        self.dismissController(self)
    }
    
}
