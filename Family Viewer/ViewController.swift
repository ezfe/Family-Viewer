//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var peopleCountLabel: NSTextField!
    @IBOutlet weak var personSelectPopup: NSPopUpButton!
    
    var hasTree: Bool {
        get {
            if let _ = self.representedObject as? Tree {
                return true
            } else {
                return false
            }
        }
    }
    
    var popupArray = [Person]()
    
    var tree = Tree() {
        didSet {
            self.updateViewFromTree()
        }
    }
    
    
    override func viewDidLoad() {
        
    }

    override var representedObject: AnyObject? {
        set(newValue) {
            if let newTree = newValue as? Tree {
                //Save new value if it is a Tree
                self.tree = newTree
            } else {
                //Do nothing if new value isn't a Tree
                return
            }
        }
        get {
            //Return the tree as an AnyObject
            return self.tree as AnyObject
        }
    }
    
    func updateViewFromTree() {
        self.filenameLabel.stringValue = "Family Tree"
        self.peopleCountLabel.stringValue = self.tree.description
        self.personSelectPopup.addItemsWithTitles(self.tree.indexOfPeople)
        
        print(self.tree.dictionary.writeToFile("/Users/ezekielelin/Desktop/test.xml", atomically: true))
    }
    
    @IBAction func selectNewPerson(sender: AnyObject) {
        if self.personSelectPopup.indexOfSelectedItem == 0 {
            return
        }
        let person = self.tree.people[self.personSelectPopup.indexOfSelectedItem - 1]
        print(person.description)
        print("\(person.parentA), \(person.parentB)")
        print(person.children)
        print(person.birth.date)
        if !person.isAlive {
            print(person.death.date)
        }
    }
}

