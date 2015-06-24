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
    
    @IBOutlet weak var horizontalBar: NSBox!
    
    override func viewDidLoad() {
        updateViewNoTree()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeDidUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedParent:", name: "com.ezekielelin.addedParent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedDefaultsFilePath", name: "com.ezekielelin.updatedDefaults_FilePath", object: nil)
    }
    
    @IBAction func openLastFile(sender: AnyObject) {
        print("Posting notification to open last file")
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.openLastFile", object: self)
    }
    
    func updatedDefaultsFilePath() {
        updateViewNoTree()
    }
    
    func updateViewNoTree() {
        self.peopleCountLabel.hidden = true
        self.openLastFileButton.hidden = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let filePath = defaults.stringForKey("filePath") {
            self.openLastFileButton.title = "Open \(filePath.lastPathComponent)"
        } else {
            self.openLastFileButton.hidden = true
            self.peopleCountLabel.hidden = false
            self.peopleCountLabel.stringValue = "Use File > Open..."
        }
        self.personSelectPopup.hidden = true
        self.horizontalBar.hidden = true
        
        noPersonSelected()
    }
    
    ///The tree
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
    
    ///Update the view based on the tree
    func updateViewFromTree() {
        let cPerson: Person?
        if let cP = currentPerson() {
            cPerson = cP
        } else {
            cPerson = nil
        }
        
        self.filenameLabel.stringValue = tree.treeName 
        self.peopleCountLabel.stringValue = self.tree.description
        self.openLastFileButton.hidden = true
        self.peopleCountLabel.hidden = false
        self.personSelectPopup.hidden = false
        self.horizontalBar.hidden = false

        
        self.personSelectPopup.removeAllItems()
        self.personSelectPopup.addItemWithTitle("Choose a person")
        self.personSelectPopup.itemAtIndex(0)?.enabled = false
        self.personSelectPopup.addItemsWithTitles(self.tree.indexOfPeople)
        
        if let cPerson = cPerson {
            self.selectPerson(person: cPerson)
        } else {
            self.personSelectPopup.selectItemAtIndex(0)
            self.selectChanged(self)
        }
    }
    
    ///Tree changed
    func treeDidUpdate() {
        tree.cleanupINDICodes()
        updateViewFromTree()
    }
    
    ///Get the currently selected Person (or nil)
    func currentPerson() -> Person? {
        if self.personSelectPopup.indexOfSelectedItem == 0 {
            return nil
        }

        return self.tree.people[self.personSelectPopup.indexOfSelectedItem - 1]

    }
    
    ///When nobody is selected... (doesn't change popup)
    func noPersonSelected() {
        nameLabel.hidden = true
        nameField.hidden = true
        editName.hidden = true
        
        birthLabel.hidden = true
        birthLocationLabel.hidden = true
        birthDateLabel.hidden = true
        editBirthButton.hidden = true
        
        parentALabel.hidden = true
        parentAField.hidden = true
        removeParentA.hidden = true
        addParentA.hidden = true
        viewParentA.hidden = true
        
        parentBLabel.hidden = true
        parentBField.hidden = true
        removeParentB.hidden = true
        addParentB.hidden = true
        viewParentB.hidden = true
    }
    
    ///Show Person ``person``
    func selectPerson(person p: Person) {
        personSelectPopup.selectItemWithTitle(p.description)
        
        guard let person = currentPerson() else {
            noPersonSelected()
            return
        }
        
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
    }
    
    @IBAction func viewParentA(sender: AnyObject) {
        if let parentA = currentPerson()?.parentA {
            selectPerson(person: parentA)
        }
    }
    
    @IBAction func viewParentB(sender: AnyObject) {
        if let parentB = currentPerson()?.parentB {
            selectPerson(person: parentB)
        }
    }
    
    @IBAction func removeParentA(sender: AnyObject) {
        if let person = currentPerson() {
            person.parentA = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
            selectPerson(person: person)
        }
    }
    
    @IBAction func removeParentB(sender: AnyObject) {
        if let person = currentPerson() {
            person.parentB = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
            selectPerson(person: person)
        }
    }
    
    @IBAction func editName(sender: AnyObject) {
        print("NO")
    }

    ///Called when the selection changes.
    @IBAction func selectChanged(sender: AnyObject) {
        if let person = currentPerson() {
            selectPerson(person: person)
        }
    }
    
    func addedParent(notification: NSNotification) {
        selectPerson(person: notification.userInfo!["newPerson"] as! Person)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let sender = sender as? NSButton {
            if let destination = segue.destinationController as? AddParentViewController, cPerson = self.currentPerson() {
                destination.tree = self.tree
                destination.parentTo = cPerson
                if sender.identifier == "addParentA" {
                    destination.A_B = "A"
                } else if sender.identifier == "addParentB" {
                    destination.A_B = "B"
                }
                return
            }
            if let destination = segue.destinationController as? EditNameViewController, cPerson = self.currentPerson() {
                destination.person = cPerson
                return
            }
            if let destination = segue.destinationController as? BirthdayViewController, cPerson = self.currentPerson() {
                destination.person = cPerson
                return
            }
        }
    }
}

