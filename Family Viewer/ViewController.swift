//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource, NSTableViewDataSource, NSTableViewDelegate {
    //MARK: Instance Variables
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var peopleCountLabel: NSTextField!
    
    @IBOutlet weak var horizontalBar: NSBox!
    
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var detailTable: NSTableView!
    
    ///The tree
    var tree: Tree? = nil
    
    var personDetail: [[String]] = Array<Array<String>>()
    var personLinks = Dictionary<Int, Person>()
    var actionsTypes = Dictionary<Int, TableActions>()
    
    //MARK:-
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTree", name: "com.ezekielelin.treeIsReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeDidUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedParent:", name: "com.ezekielelin.addedParent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedDefaultsFilePath", name: "com.ezekielelin.updatedDefaults_FilePath", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPersonFromNotification", name: "com.ezekielelin.addPerson", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteCurrentPerson", name: "com.ezekielelin.deleteCurrentPerson", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addParentA", name: "com.ezekielelin.addMother", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addParentB", name: "com.ezekielelin.addFather", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeParentA", name: "com.ezekielelin.removeMother", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeParentB", name: "com.ezekielelin.removeFather", object: nil)
        
        detailTable.doubleAction = "doubleClickDetail"
    }
    
    //MARK:-
    //MARK: Table
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            selectPerson(person: tree!.people[row], isFromTable: true)
            return true;
        case .PersonDetailTable:
            return true;
        }
    }
    
    func doubleClickDetail() {
        
        if let person = personLinks[detailTable.clickedRow] {
            selectPerson(person: person)
            return
        }
        if let action = actionsTypes[detailTable.clickedRow] {
            switch action {
            case .EditName:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("EditNameViewController") as! EditNameViewController
                vc.person = selectedPerson
                self.presentViewController(vc, asPopoverRelativeToRect: detailTable.rectOfRow(detailTable.clickedRow), ofView: detailTable, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient)
            case .EditBirth:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("BirthdayViewController") as! BirthdayViewController
                vc.person = selectedPerson
                self.presentViewController(vc, asPopoverRelativeToRect: detailTable.rectOfRow(detailTable.clickedRow), ofView: detailTable, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient)
            case .EditDeath:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("DeathViewController") as! DeathViewController
                vc.person = selectedPerson
                self.presentViewController(vc, asPopoverRelativeToRect: detailTable.rectOfRow(detailTable.clickedRow), ofView: detailTable, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient)
                return
            case .SetParentA:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
                vc.tree = self.tree!
                vc.parentTo = selectedPerson
                vc.A_B = "A"
                self.presentViewController(vc, asPopoverRelativeToRect: detailTable.rectOfRow(detailTable.clickedRow), ofView: detailTable, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient)
                return
            case .SetParentB:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
                vc.parentTo = selectedPerson
                vc.tree = self.tree!
                vc.A_B = "B"
                self.presentViewController(vc, asPopoverRelativeToRect: detailTable.rectOfRow(detailTable.clickedRow), ofView: detailTable, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient)
                return
            case .ToggleSex:
                selectedPerson.sex = (selectedPerson.sex == Sex.Female ? Sex.Male : Sex.Female)
                updateViewFromTree()
            case .TreeView:
                let vc = self.storyboard?.instantiateControllerWithIdentifier("TreeViewController") as! TreeViewController
                vc.tree = self.tree!
                self.presentViewControllerAsSheet(vc)
            }
        }
    }
    
    @IBAction func tableClick(sender: AnyObject) {
        if table.selectedRow == -1 {
            return
        }
        selectPerson(person: tree!.people[table.selectedRow], isFromTable: true)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch getXcodeTag(tableView.tag) {
        case .PersonDetailTable:
            personDetail.removeAll()
            constructPersonDetail()
            return personDetail.count
        case .MainBrowserTable:
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.tree.people.count
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            let v = tableView.makeViewWithIdentifier("PersonCell", owner: self) as! NSTableCellView
            
            v.textField?.stringValue = tree!.people[row].description
            
            return v
        case .PersonDetailTable:
            let v = tableView.makeViewWithIdentifier("LabelCell", owner: self) as! NSTableCellView
            let c = tableView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            
            if (tableColumn?.identifier == "LabelColumn") {
                v.textField?.stringValue = personDetail[row][0]
                return v
            } else {
                c.textField?.stringValue = personDetail[row][1]
                return c
            }
            
        }
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
        tree?.sortPeople(tree!.nextSort)
        table.reloadData()
        
        return false
    }
    
    func constructPersonDetail() {
        personDetail.removeAll()
        personLinks.removeAll()
        actionsTypes.removeAll()
        
        guard let _ = tree else {
            return
        }
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Name")
        personDetail[personDetail.count - 1].append(selectedPerson.description)
        actionsTypes[personDetail.count - 1] = TableActions.EditName
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Tree")
        personDetail[personDetail.count - 1].append("")
        actionsTypes[personDetail.count - 1] = TableActions.TreeView
        
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Sex")
        personDetail[personDetail.count - 1].append(selectedPerson.sex!.rawValue)
        actionsTypes[personDetail.count - 1] = TableActions.ToggleSex
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Date of Birth")
        if selectedPerson.birth.date.isSet() {
            personDetail[personDetail.count - 1].append(selectedPerson.birth.date.description)
        } else {
            personDetail[personDetail.count - 1].append("Date Not Set")
        }
        actionsTypes[personDetail.count - 1] = TableActions.EditBirth
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Location of Birth")
        if (selectedPerson.birth.location == "") {
            personDetail[personDetail.count - 1].append("Unknown")
        } else {
            personDetail[personDetail.count - 1].append(selectedPerson.birth.location)
        }
        actionsTypes[personDetail.count - 1] = TableActions.EditBirth
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Date of Death")
        if (!selectedPerson.isAlive) {
            if selectedPerson.death.date.isSet() {
                personDetail[personDetail.count - 1].append(selectedPerson.death.date.description)
            } else {
                personDetail[personDetail.count - 1].append("Date Not Set")
            }
        } else {
            personDetail[personDetail.count - 1].append("Still Alive")
        }
        actionsTypes[personDetail.count - 1] = TableActions.EditDeath
        
        if !selectedPerson.isAlive {
            personDetail.append(Array<String>())
            personDetail[personDetail.count - 1].append("Location of Death")
            actionsTypes[personDetail.count - 1] = TableActions.EditDeath
            personDetail[personDetail.count - 1].append(selectedPerson.death.location)
        }
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Mother")
        if let parentA = selectedPerson.parentA {
            personDetail[personDetail.count - 1].append(parentA.description)
            personLinks[personDetail.count - 1] = parentA;
        } else {
            personDetail[personDetail.count - 1].append("[No Mother – Double-click to add]")
            actionsTypes[personDetail.count - 1] = TableActions.SetParentA
        }
        
        personDetail.append(Array<String>())
        personDetail[personDetail.count - 1].append("Father")
        if let parentB = selectedPerson.parentB {
            personDetail[personDetail.count - 1].append(parentB.description)
            personLinks[personDetail.count - 1] = parentB;
        } else {
            personDetail[personDetail.count - 1].append("[No Father – Double-click to add]")
            actionsTypes[personDetail.count - 1] = TableActions.SetParentB
        }
        
        for (i, child) in selectedPerson.children.enumerate() {
            personDetail.append(Array<String>())
            if (i == 0) {
                personDetail[personDetail.count - 1].append("Children")
            } else {
                personDetail[personDetail.count - 1].append("")
            }
            personDetail[personDetail.count - 1].append(child.description)
            personLinks[personDetail.count - 1] = child;
        }
        
        for (i, sibling) in selectedPerson.allSiblings.enumerate() {
            personDetail.append(Array<String>())
            if (i == 0) {
                personDetail[personDetail.count - 1].append("Siblings")
            } else {
                personDetail[personDetail.count - 1].append("")
            }
            personDetail[personDetail.count - 1].append(sibling.description)
            personLinks[personDetail.count - 1] = sibling;
        }
        
    }
    
    //MARK:-
    
    func loadTree() {
        print("Loading tree...")
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        self.tree = appDelegate.tree
        
        guard let _ = tree else {
            assert(false, "tree is nil")
            return
        }
        
        if let selectedPersonFromTree = tree?.selectedPerson {
            selectPerson(person: selectedPersonFromTree)
            //            print(selectedPersonFromTree)
        } else {
            if tree!.people.count == 0 {
                tree?.people.append(Person(tree: tree!))
            }
            selectPerson(person: tree!.people[0])
        }
        
        table.reloadData()
        
    }
    
    func addPersonFromNotification() {
        let p = Person(tree: self.tree!)
        self.tree!.people.append(p)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        selectPerson(person: p)
    }
    
    ///Update the view based on the tree
    func updateViewFromTree() {
        self.filenameLabel.stringValue = tree!.treeName
        self.horizontalBar.hidden = false
        
        self.selectPerson(person: self.selectedPerson)
        
        table.reloadData()
        
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
    func selectPerson(person person: Person, isFromTable: Bool = false) {
        
        print("Received request to select \(person)")
        
        if !isFromTable {
            print("Not called by table, informing table")
            
            if let personIndex = tree!.getIndexOfPerson(person) {
                let indexes = NSIndexSet(index: personIndex)
                table.selectRowIndexes(indexes, byExtendingSelection: false)
                table.scrollRowToVisible(personIndex)
            } else {
                print("\(person) doesn't exist in the tree")
                return
            }
        }
        
        selectedPerson = person
        
        print("Selected \(person)")
        detailTable.reloadData()
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.mainViewPersonChange", object: nil, userInfo: ["id": person.INDI])
    }
    
    func removeParentA() {
        selectedPerson.parentA = nil
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
    }
    
    func removeParentB() {
        selectedPerson.parentB = nil
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.tree)
    }
    
    func addedParent(notification: NSNotification) {
        selectPerson(person: notification.userInfo!["newPerson"] as! Person)
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
        if tree!.removePerson(selectedPerson) {
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