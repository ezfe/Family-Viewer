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
    ///Label that shows the name
    @IBOutlet weak var nameField: NSTextField!
    ///Label for Parent A ("Parent A:")
    @IBOutlet weak var parentALabel: NSTextField!
    ///Label for Parent A's name
    @IBOutlet weak var parentAField: NSTextField!
    ///Label for Parent B ("Parent B:")
    @IBOutlet weak var parentBLabel: NSTextField!
    ///Label for Parent B's name
    @IBOutlet weak var parentBField: NSTextField!
    ///Add Parent A button
    @IBOutlet weak var addParentA: NSButton!
    ///Add Parent B button
    @IBOutlet weak var addParentB: NSButton!
    ///Remove Parent A
    @IBOutlet weak var removeParentA: NSButton!
    ///Remove Parent B
    @IBOutlet weak var removeParentB: NSButton!
    ///View Parent A
    @IBOutlet weak var viewParentA: NSButton!
    ///View Parent B
    @IBOutlet weak var viewParentB: NSButton!
    ///Edit name
    @IBOutlet weak var editName: NSButton!
    ///Label for birth ("Birth:")
    @IBOutlet weak var birthLabel: NSTextField!
    ///Label for birth date
    @IBOutlet weak var birthDateLabel: NSTextField!
    ///Label for birth location
    @IBOutlet weak var birthLocationLabel: NSTextField!
    ///Edit birth
    @IBOutlet weak var editBirthButton: NSButton!
    ///Label for death ("Death:")
    @IBOutlet weak var deathLabel: NSTextField!
    ///Label for death date (used for "not dead" if not dead)
    @IBOutlet weak var deathDateLabel: NSTextField!
    ///Label for death location (Leave blank if not dead)
    @IBOutlet weak var deathLocationLabel: NSTextField!
    ///Edit death
    @IBOutlet weak var editDeathButton: NSButton!
    
    
    @IBOutlet weak var horizontalBar: NSBox!
 
    ///The tree
    var tree: Tree? = nil
    
    override func viewDidLoad() {

        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        tree = appDelegate.tree
        
//        updateViewFromTree()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeDidUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedParent:", name: "com.ezekielelin.addedParent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarTableRowChange:", name: "com.ezekielelin.sidebarTableRowChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedDefaultsFilePath", name: "com.ezekielelin.updatedDefaults_FilePath", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPersonFromNotification", name: "com.ezekielelin.addPerson", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteCurrentPerson", name: "com.ezekielelin.deleteCurrentPerson", object: nil)
        
        guard let _ = tree else {
            assert(false,"tree is nil")
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
        if let _ = currentPerson {
            print("No issues!")
        } else {
            if tree!.people.count == 0 {
                tree!.people.append(Person(tree: tree!))
            }
            self.currentPerson = tree!.people[0]
            print("Uh ohh, fixed though")
        }
        self.filenameLabel.stringValue = tree!.treeName
        self.peopleCountLabel.stringValue = self.tree!.description
        self.peopleCountLabel.hidden = false
        self.horizontalBar.hidden = false
        
        self.selectPerson(person: self.currentPerson!)
    }
    
    ///Tree changed
    func treeDidUpdate() {
        tree!.cleanupINDICodes()
        updateViewFromTree()
    }
    
    var currentPerson: Person? = nil {
        didSet {
            tree!.selectedPerson = self.currentPerson
        }
    }
    
    ///Show Person ``person``
    func selectPerson(person person: Person) {
        
//        guard let person = currentPerson else {
//            assert(false,"It done broke")
//            return
//        }

        currentPerson = person
        
        print("Received request to select \(person)")

//      var views = Array<NSView>()
        
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
            birthDateLabel.stringValue = "No Date Set"
        }
        
        if person.birth.location == "" {
            birthLocationLabel.stringValue = "No Location Set"
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
            deathDateLabel.stringValue = "No Date Set"
        }
        
        if person.death.location == "" {
            deathLocationLabel.stringValue = "No Location Set"
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
        if let parentA = currentPerson?.parentA {
            selectPerson(person: parentA)
        }
    }
    
    @IBAction func viewParentB(sender: AnyObject) {
        if let parentB = currentPerson?.parentB {
            selectPerson(person: parentB)
        }
    }
    
    @IBAction func removeParentA(sender: AnyObject) {
        if let person = currentPerson {
            person.parentA = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
            selectPerson(person: person)
        }
    }
    
    @IBAction func removeParentB(sender: AnyObject) {
        if let person = currentPerson {
            person.parentB = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
            selectPerson(person: person)
        }
    }
    
    @IBAction func editName(sender: AnyObject) {
        print("NO")
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
            if let destination = segue.destinationController as? AddParentViewController, cPerson = self.currentPerson {
                destination.tree = self.tree!
                destination.parentTo = cPerson
                if sender.identifier == "addParentA" {
                    destination.A_B = "A"
                } else if sender.identifier == "addParentB" {
                    destination.A_B = "B"
                }
                return
            }
            if let destination = segue.destinationController as? EditNameViewController, cPerson = self.currentPerson {
                destination.person = cPerson
                return
            }
            if let destination = segue.destinationController as? BirthdayViewController, cPerson = self.currentPerson {
                destination.person = cPerson
                return
            }
            if let destination = segue.destinationController as? DeathViewController, cPerson = self.currentPerson {
                destination.person = cPerson
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

