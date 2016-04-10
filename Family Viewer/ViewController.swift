//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate {
    //MARK: Instance Variables
    @IBOutlet weak var filenameLabel: NSTextField!
    
    @IBOutlet weak var horizontalBar: NSBox!
    
    @IBOutlet weak var mainBrowserTable: NSTableView!
    @IBOutlet weak var parentsTable: NSTableView!
    @IBOutlet weak var childrenTable: NSTableView!
    
    @IBOutlet weak var profilePhoto: NSImageView!
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var deathBirthSublabel: NSTextField!
    
    @IBOutlet weak var genderLabel: NSTextField!
    @IBOutlet weak var genderEditor: NSPopUpButton!
    
    @IBOutlet weak var birthLabel: NSTextField!
    @IBOutlet weak var deathLabel: NSTextField!
    
    @IBOutlet var notesField: NSTextView!
    
    ///The tree
    var tree: Tree? = nil
    
    var personDetail: [[String]] = Array<Array<String>>()
    var personLinks = Dictionary<Int, Person>()
    var actionsTypes = Dictionary<Int, TableActions>()
    
    //MARK:-
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loadTree), name: "com.ezekielelin.treeIsReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.treeDidUpdate), name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.addedParent(_:)), name: "com.ezekielelin.addedParent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.addPersonFromNotification), name: "com.ezekielelin.addPerson", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deleteCurrentPerson), name: "com.ezekielelin.deleteCurrentPerson", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.removeParentA), name: "com.ezekielelin.removeMother", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.removeParentB), name: "com.ezekielelin.removeFather", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setParentA), name: "com.ezekielelin.addMother", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setParentB), name: "com.ezekielelin.addFather", object: nil)
        
        let sexGesture = NSClickGestureRecognizer()
        sexGesture.buttonMask = 0x1 // left mouse
        sexGesture.numberOfClicksRequired = 2
        sexGesture.target = self
        sexGesture.action = #selector(startEditSex)
        genderLabel.addGestureRecognizer(sexGesture)
        
        
        let nameGesture = NSClickGestureRecognizer()
        nameGesture.buttonMask = 0x1 // left mouse
        nameGesture.numberOfClicksRequired = 2
        nameGesture.target = self
        nameGesture.action = #selector(editName)
        nameLabel.addGestureRecognizer(nameGesture)
        
        let birthGesture = NSClickGestureRecognizer()
        birthGesture.buttonMask = 0x1 // left mouse
        birthGesture.numberOfClicksRequired = 2
        birthGesture.target = self
        birthGesture.action = #selector(editBirth)
        birthLabel.addGestureRecognizer(birthGesture)
        
        let deathGesture = NSClickGestureRecognizer()
        deathGesture.buttonMask = 0x1 // left mouse
        deathGesture.numberOfClicksRequired = 2
        deathGesture.target = self
        deathGesture.action = #selector(editDeath)
        deathLabel.addGestureRecognizer(deathGesture)
        
    }
    
    //MARK:-
    //MARK: Edit Functions
    
    func editName() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("EditNameViewController") as? EditNameViewController {
            vc.person = selectedPerson
            self.presentViewController(vc, asPopoverRelativeToRect: nameLabel.visibleRect, ofView: nameLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func editBirth() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("BirthdayViewController") as? BirthdayViewController {
            vc.person = selectedPerson
            self.presentViewController(vc, asPopoverRelativeToRect: birthLabel.visibleRect, ofView: birthLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func editDeath() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("DeathViewController") as? DeathViewController {
            vc.person = selectedPerson
            self.presentViewController(vc, asPopoverRelativeToRect: deathLabel.visibleRect, ofView: deathLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func startEditSex() {
        genderLabel.hidden = true
        genderEditor.hidden = false
        
        if let selectedSex = selectedPerson?.sex?.rawValue {
            genderEditor.selectItemWithTitle(selectedSex)
            genderEditor.performClick(self)
        }
    }
    
    @IBAction func editSex(sender: AnyObject) {
        
        guard let popup = sender as? NSPopUpButton else {
            return
        }
        
        if let sex = popup.titleOfSelectedItem, sexItem = Sex(rawValue: sex) {
            selectedPerson?.sex = sexItem
            
            genderLabel.hidden = false
            genderEditor.hidden = true
            
            treeDidUpdate()
        }
    }
    
    func setParentA() {
        guard let tree = self.tree else {
            return
        }
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
        vc.tree = tree
        vc.parentTo = selectedPerson
        vc.A_B = "A"
        self.presentViewController(vc, asPopoverRelativeToRect: parentsTable.visibleRect, ofView: parentsTable, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
    }
    
    func setParentB() {
        guard let tree = self.tree else {
            return
        }
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
        vc.parentTo = selectedPerson
        vc.tree = tree
        vc.A_B = "B"
        self.presentViewController(vc, asPopoverRelativeToRect: parentsTable.visibleRect, ofView: parentsTable, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
    }
    
    func textDidChange(notification: NSNotification) {
        if let p = self.selectedPerson, n = notesField.string {
            p.notes = n
        }
    }
    
    //MARK: -
    //MARK: Table Functions
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            selectPerson(person: tree!.people[row], isFromTable: true)
            return true
        case .ChildrenTable, .ParentsTable:
            return true
        }
    }
    
    @IBAction func tableClick(sender: AnyObject) {
        if let tree = self.tree where mainBrowserTable.selectedRow == -1 {
            selectPerson(person: tree.people[mainBrowserTable.selectedRow], isFromTable: true)
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch getXcodeTag(tableView.tag) {
        case .ParentsTable:
            if let p = selectedPerson {
                return p.parents.count
            } else {
                return 0
            }
        case .ChildrenTable:
            if let p = selectedPerson {
                return p.children.count
            } else {
                return 0
            }
        case .MainBrowserTable:
            if let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate {
                return appDelegate.tree.people.count
            } else {
                return 0
            }
        }
    }
    
    /**
     This function manages the table view and and populates it with the necessary values.
     */
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            guard let v = tableView.makeViewWithIdentifier("PersonCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            guard let tree = self.tree else {
                treeIsNilError()
                return nil
            }
            
            v.textField?.stringValue = tree.people[row].description
            
            return v
        case .ChildrenTable:
            guard let v = tableView.makeViewWithIdentifier("ChildCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = selectedPerson {
                v.textField?.stringValue = p.children[row].description
            }
            
            return v
        case .ParentsTable:
            guard let v = tableView.makeViewWithIdentifier("ParentCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = selectedPerson {
                v.textField?.stringValue = p.parents[row].description
            }
            
            return v
        }
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
        if let tree = self.tree {
            tree.sortPeople(tree.nextSort)
            mainBrowserTable.reloadData()
        } else {
            treeIsNilError()
        }
        
        return false
    }
    
    //MARK:-
    
    func loadTree() {
        print("Loading tree...")
        
        guard let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate else {
            print("\(#function)@\(#line): unable to find App Delegate")
            return
        }
        
        self.tree = appDelegate.tree
        
        guard let tree = self.tree else {
            print("\(#function)@\(#line): self.tree is nil")
            return
        }
        
        if let selectedPersonFromTree = tree.selectedPerson {
            selectPerson(person: selectedPersonFromTree)
        } else {
            if tree.people.count == 0 {
                tree.people.append(Person(tree: tree))
            }
            selectPerson(person: tree.people[0])
        }
        
        updateViewFromTree()
        
        mainBrowserTable.reloadData()
        
    }
    
    func addPersonFromNotification() {
        let p = Person(tree: self.tree!)
        self.tree!.people.append(p)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        selectPerson(person: p)
    }
    
    ///Update the view based on the tree
    func updateViewFromTree() {
        if let tree = self.tree {
            self.filenameLabel.stringValue = tree.treeName
        }
        
        self.horizontalBar.hidden = false
        
        if let selectedPerson = self.selectedPerson {
            self.selectPerson(person: selectedPerson)
        }
        
        mainBrowserTable.reloadData()
    }
    
    ///Tree changed
    func treeDidUpdate() {
        if let tree = self.tree {
            tree.cleanupINDICodes()
            updateViewFromTree()
        }
    }
    
    var selectedPerson: Person? {
        set (p) {
            if let tree = self.tree {
                tree.selectedPerson = p
            } else {
                treeIsNilError()
            }
        }
        
        get {
            guard let tree = self.tree else {
                return nil
            }
            if let p = tree.selectedPerson {
                return p
            } else {
                if tree.people.count == 0 {
                    return nil
                } else {
                    tree.selectedPerson = tree.people[0]
                    return tree.selectedPerson
                }
            }
        }
    }
    
    ///Show Person ``person``
    func selectPerson(person person: Person, isFromTable: Bool = false) {
        
        guard let tree = self.tree else {
            treeIsNilError()
            return
        }
        
        print("Received request to select \(person)")
        
        if !isFromTable {
            print("Not called by table, informing table")
            
            if let personIndex = tree.getIndexOfPerson(person) {
                let indexes = NSIndexSet(index: personIndex)
                mainBrowserTable.selectRowIndexes(indexes, byExtendingSelection: false)
                mainBrowserTable.scrollRowToVisible(personIndex)
            } else {
                print("\(person) doesn't exist in the tree")
                return
            }
        }
        
        selectedPerson = person
        
        print("Relationship Tests:")
        print(tree.getPerson(givenName: "Ezekiel", familyName: "Elin")!.relationTo(person: person))
        
        print("Selected \(person)")
        
        nameLabel.stringValue = person.description
        
        if person.isAlive {
            if person.birth.date.isSet() {
                deathBirthSublabel.stringValue = "\(person.birth.date.description) - "
            } else {
                deathBirthSublabel.stringValue = "Birthday Unknown"
            }
        } else {
            let birthString: String
            if person.birth.date.isSet() {
                birthString = person.birth.date.description
            } else {
                birthString = "Unknown"
            }
            
            let deathString: String
            if person.death.date.isSet() {
                deathString = person.death.date.description
            } else {
                deathString = "Unknown"
            }
            deathBirthSublabel.stringValue = "\(birthString) - \(deathString)"
        }
        
        if let sex = person.sex?.rawValue {
            genderLabel.stringValue = sex
        } else {
            genderLabel.stringValue = "Sex Unknown"
        }
        
        if person.birth.date.isSet() {
            birthLabel.stringValue = person.birth.date.description
        } else if !person.birth.location.isEmpty {
            birthLabel.stringValue = person.birth.location
        } else {
            birthLabel.stringValue = "Date Unknown"
        }
        
        if person.isAlive {
            deathLabel.stringValue = "Alive"
        } else if person.death.date.isSet() {
            deathLabel.stringValue = person.death.date.description
        } else if !person.death.location.isEmpty {
            deathLabel.stringValue = person.death.location
        } else {
            deathLabel.stringValue = "Date Unknown"
        }
        
        parentsTable.reloadData()
        childrenTable.reloadData()
        
        notesField.string = person.notes
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.mainViewPersonChange", object: nil, userInfo: ["id": person.INDI])
    }
    
    func removeParentA() {
        if let selectedPerson = self.selectedPerson {
            selectedPerson.parentA = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
        }
    }
    
    func removeParentB() {
        if let selectedPerson = self.selectedPerson {
            selectedPerson.parentB = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
        }
    }
    
    func addedParent(notification: NSNotification) {
        if let p = notification.userInfo?["newPerson"] as? Person {
            selectPerson(person: p)
        }
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
        print("Received request to delete current person")
        print("Deleting \(selectedPerson)")
        if let tree = self.tree, selectedPerson = self.selectedPerson where tree.removePerson(selectedPerson) {
            print("Success")
            updateViewFromTree()
        } else {
            displayAlert("Error", message: "An unexpected error occurred")
        }
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