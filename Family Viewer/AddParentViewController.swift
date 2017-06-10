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
        
        self.popupChooser.addItems(withTitles: self.tree.people.map { $0.description })
    }

    @IBAction func setParent(_ sender: AnyObject) {
        guard let parentTo = parentTo else {
            return
        }
        if self.popupChooser.indexOfSelectedItem == 0 {
            return
        }
        
        let parent = self.tree.people[self.popupChooser.indexOfSelectedItem - 1]

        if parentTo == parent {
            displayAlert(title: "Operation not Permitted", message: "You may not be your own parent")
            return
        }

        if self.A_B == "A" {
            parentTo.parentA = parent
        } else if self.A_B == "B" {
            parentTo.parentB = parent
        }
        NotificationCenter.default.post(name: .FVTreeDidUpdate, object: nil)
        self.dismiss(self)
    }

    @IBAction func createNewPerson(_ sender: AnyObject) {
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
        NotificationCenter.default.post(name: .FVTreeDidUpdate, object: nil)
        NotificationCenter.default.post(name: .FVAddedParent, object: nil, userInfo: ["newPerson": newPerson, "parentTo": parentTo, "A_B": A_B])
        self.dismiss(self)
    }
}
