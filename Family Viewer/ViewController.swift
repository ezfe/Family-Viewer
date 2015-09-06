//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource {
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var peopleCountLabel: NSTextField!
    @IBOutlet weak var openLastFileButton: NSButton!
    
    ///Label for the name ("Name:")
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    
    ///Label for Parent A ("Parent A:")
    @IBOutlet weak var parentALabel: NSTextField!
    @IBOutlet weak var parentAField: NSTextField!
    
    ///Label for Parent B ("Parent B:")
    @IBOutlet weak var parentBLabel: NSTextField!
    @IBOutlet weak var parentBField: NSTextField!

    @IBOutlet weak var addParentA: NSButton!
    @IBOutlet weak var addParentB: NSButton!
    
    @IBOutlet weak var removeParentA: NSButton!
    @IBOutlet weak var removeParentB: NSButton!

    @IBOutlet weak var viewParentA: NSButton!
    @IBOutlet weak var viewParentB: NSButton!

    @IBOutlet weak var editName: NSButton!
    
    ///Label for birth ("Birth:")
    @IBOutlet weak var birthLabel: NSTextField!
    @IBOutlet weak var birthDateLabel: NSTextField!
    @IBOutlet weak var birthLocationLabel: NSTextField!
    @IBOutlet weak var editBirthButton: NSButton!
    
    ///Label for death ("Death:")
    @IBOutlet weak var deathLabel: NSTextField!
    ///Label for death date (used for "not dead" if not dead)
    @IBOutlet weak var deathDateLabel: NSTextField!
    ///Label for death location (Leave blank if not dead)
    @IBOutlet weak var deathLocationLabel: NSTextField!
    @IBOutlet weak var editDeathButton: NSButton!
    
    @IBOutlet weak var horizontalBar: NSBox!
 
    ///The tree
    var tree: Tree? = nil
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTree", name: "com.ezekielelin.treeIsReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeDidUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedParent:", name: "com.ezekielelin.addedParent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarTableRowChange:", name: "com.ezekielelin.sidebarTableRowChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedDefaultsFilePath", name: "com.ezekielelin.updatedDefaults_FilePath", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPersonFromNotification", name: "com.ezekielelin.addPerson", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteCurrentPerson", name: "com.ezekielelin.deleteCurrentPerson", object: nil)
    }
    
    func loadTree() {
        print("Loading tree...")
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        tree = appDelegate.tree
        
        guard let _ = tree else {
            assert(false, "tree is nil")
            return
        }
        
        if let selectedPersonFromTree = tree?.selectedPerson {
            selectPerson(person: selectedPersonFromTree)
            print(selectedPersonFromTree)
        } else {
            if tree!.people.count == 0 {
                tree?.people.append(Person(tree: tree!))
            }
            selectPerson(person: tree!.people[0])
        }
        

    }
    
    func addPersonFromNotification() {
        let p = Person(tree: self.tree!)
        self.tree!.people.append(p)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        selectPerson(person: p)
    }
    
    func updatedDefaultsFilePath() {

    }
    
    ///Update the view based on the tree
    func updateViewFromTree() {
        self.filenameLabel.stringValue = tree!.treeName
        self.peopleCountLabel.stringValue = self.tree!.description
        self.peopleCountLabel.hidden = false
        self.horizontalBar.hidden = false
        
        self.selectPerson(person: self.selectedPerson)
    }
    
    ///Tree changed
    func treeDidUpdate() {
        guard let tree = self.tree else {
            return
        }
        tree.cleanupINDICodes()
        updateViewFromTree()
    }
    
    var selectedPerson: Person {
        set (p) {
            tree!.selectedPerson = p
        }
        
        get {
            guard let tree = tree else {
                assert(false, "No tree")
                return Person(tree: Tree()) //Xcode doesn't like it if I don't return something here
            }
            if let p = tree.selectedPerson {
                return p
            } else {
                if tree.people.count == 0 {
                    tree.people.append(Person(tree: tree))
                }
                tree.selectedPerson = tree.people[0]
                return tree.selectedPerson!
            }
        }
    }
    
    ///Show Person ``person``
    func selectPerson(person person: Person) {
        
        let NO_DATE_STRING = "No Date Set"
        let NO_LOCATION_STRING = "No Location Set"
        
        selectedPerson = person
        
        print("Received request to select \(person)")
        
        nameLabel.hidden = false
        nameField.hidden = false
        editName.hidden = false
        nameField.stringValue = person.description
        
        parentALabel.hidden = false
        if let parentA = person.parentA {
            addParentA.hidden = true
            removeParentA.hidden = false
            viewParentA.hidden = false
            parentAField.hidden = false
            parentAField.stringValue = parentA.description
        } else {
            addParentA.hidden = false
            removeParentA.hidden = true
            viewParentA.hidden = true
            parentAField.hidden = true
        }
        
        parentBLabel.hidden = false
        if let parentB = person.parentB {
            addParentB.hidden = true
            removeParentB.hidden = false
            viewParentB.hidden = false
            parentBField.hidden = false
            parentBField.stringValue = parentB.description
        } else {
            addParentB.hidden = false
            removeParentB.hidden = true
            viewParentB.hidden = true
            parentBField.hidden = true
        }
        
        birthLabel.hidden = false
        birthLocationLabel.hidden = false
        birthDateLabel.hidden = false
        editBirthButton.hidden = false
        
        if person.birth.date.isSet() {
            birthDateLabel.stringValue = person.birth.date.description
        } else {
            birthDateLabel.stringValue = NO_DATE_STRING
        }
        
        if person.birth.location == "" {
            birthLocationLabel.stringValue = NO_LOCATION_STRING
        } else {
            birthLocationLabel.stringValue = person.birth.location
        }
        
        deathLabel.hidden = false
        deathLocationLabel.hidden = false
        deathDateLabel.hidden = false
        editDeathButton.hidden = false
        
        if person.death.date.isSet() {
            deathDateLabel.stringValue = person.death.date.description
        } else {
            deathDateLabel.stringValue = NO_DATE_STRING
        }
        
        if person.death.location == "" {
            deathLocationLabel.stringValue = NO_LOCATION_STRING
        } else {
            deathLocationLabel.stringValue = person.birth.location
        }
        
        if person.isAlive {
            deathDateLabel.stringValue = "\(person.description) is still alive"
            deathLocationLabel.stringValue = ""
        }
        
        
//        let stackView = NSStackView(views: views)
//        stackView.orientation = NSUserInterfaceLayoutOrientation.Vertical
        
        print("Selected \(person)")
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.mainViewPersonChange", object: nil, userInfo: ["id": person.INDI])
    }
    
    @IBAction func viewParentA(sender: AnyObject) {
        if let parentA = selectedPerson.parentA {
            selectPerson(person: parentA)
        }
    }
    
    @IBAction func viewParentB(sender: AnyObject) {
        if let parentB = selectedPerson.parentB {
            selectPerson(person: parentB)
        }
    }
    
    @IBAction func removeParentA(sender: AnyObject) {
        selectedPerson.parentA = nil
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
    }
    
    @IBAction func removeParentB(sender: AnyObject) {
        selectedPerson.parentB = nil
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
    }
    
    func addedParent(notification: NSNotification) {
        selectPerson(person: notification.userInfo!["newPerson"] as! Person)
    }
    
    func sidebarTableRowChange(notification: NSNotification) {
        let row = notification.userInfo!["row"] as! Int
        print("Selecting person @:\(row)")
        print("That means \(tree!.people[row])")
        selectPerson(person: tree!.people[row])
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let sender = sender as? NSButton {
            if let destination = segue.destinationController as? AddParentViewController {
                destination.tree = self.tree!
                destination.parentTo = selectedPerson
                if sender.identifier == "addParentA" {
                    destination.A_B = "A"
                } else if sender.identifier == "addParentB" {
                    destination.A_B = "B"
                }
                return
            }
            if let destination = segue.destinationController as? EditNameViewController {
                destination.person = selectedPerson
                return
            }
            if let destination = segue.destinationController as? BirthdayViewController {
                destination.person = selectedPerson
                return
            }
            if let destination = segue.destinationController as? DeathViewController {
                destination.person = selectedPerson
                return
            }
        }
    }
    
    func deleteCurrentPerson() {
        displayAlert("Oops", message: "That's not finished yet")
        return
//        if let person = currentPerson {
//            for (i,p) in tree.people.enumerate() {
//                if p == person {
//                    tree.people.removeAtIndex(i)
//                    NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
//                }
//            }
//        }
    }
    
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return tree!.people.count
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return tree!.people[index].description
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let name = item as? String {
            return name
        } else {
            return nil
        }
    }

}

