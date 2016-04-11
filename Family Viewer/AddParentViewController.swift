//
//  AddParentViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/15/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import AppKit

class AddParentViewController: NSViewController {

    @IBOutlet weak var popupChooser: NSPopUpButton!
    var parentTo: Person? = nil
    var A_B: String = "A"
    var tree: Tree = Tree()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popupChooser.addItemsWithTitles(tree.peopleNameList)
    }

    @IBAction func setParent(sender: AnyObject) {
        guard let parentTo = parentTo else {
            return
        }
        if self.popupChooser.indexOfSelectedItem == 0 {
            return
        }
        
        let parent = self.tree.people[self.popupChooser.indexOfSelectedItem - 1]

        if parentTo == parent {
            displayAlert("Operation not Permitted", message: "You may not be your own parent")
            return
        }

        if self.A_B == "A" {
            parentTo.parentA = parent
        } else if self.A_B == "B" {
            parentTo.parentB = parent
        }
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        self.dismissController(self)
    }

    @IBAction func createNewPerson(sender: AnyObject) {
        guard let parentTo = parentTo else {
            return
        }
        let newPerson = Person(tree: self.tree)
        tree.people.append(newPerson)
        if self.A_B == "A" {
            parentTo.parentA = newPerson
            newPerson.sex = .Female
        } else if self.A_B == "B" {
            parentTo.parentB = newPerson
            newPerson.sex = .Male
        }
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.addedParent", object: nil, userInfo: ["newPerson":newPerson,"parentTo":parentTo,"A_B": A_B])
        self.dismissController(self)
    }
}
