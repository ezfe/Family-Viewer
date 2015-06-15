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
    
    override func viewDidLoad() {
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeDidUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        
    }
    
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
    
    var tree: Tree {
        set(newValue) {
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.tree = newValue
        }
        get {
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.tree
        }
    }
    
    func updateViewFromTree() {
        self.filenameLabel.stringValue = "Family Tree"
        self.peopleCountLabel.stringValue = self.tree.description
        self.personSelectPopup.addItemsWithTitles(self.tree.indexOfPeople)
        
//        print(self.tree.dictionary.writeToFile("/Users/ezekielelin/Desktop/test.xml",
    }
    
    func treeDidUpdate() {
        updateViewFromTree()
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

