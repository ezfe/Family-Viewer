//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate {
    //MARK: Instance Variables
    @IBOutlet weak var filenameLabel: NSTextField!
    
    @IBOutlet weak var horizontalBar: NSBox!
    
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
    var person: Person? = nil
    
    //MARK:-
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(treeDidUpdate), name: "com.ezekielelin.treeDidUpdate", object: nil)
        
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
        
        parentsTable.doubleAction = #selector(doubleClick)
        childrenTable.doubleAction = #selector(doubleClick)
        
        guard let person = self.person else {
            self.dismissController(self)
            return
        }
        
        print("Opening \(person)")
        
        setupView()
    }
    
    //MARK:-
    //MARK: Edit Functions
    
    func editName() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("EditNameViewController") as? EditNameViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeToRect: nameLabel.visibleRect, ofView: nameLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func editBirth() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("BirthdayViewController") as? BirthdayViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeToRect: birthLabel.visibleRect, ofView: birthLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func editDeath() {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("DeathViewController") as? DeathViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeToRect: deathLabel.visibleRect, ofView: deathLabel, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
        }
    }
    
    func startEditSex() {
        genderLabel.hidden = true
        genderEditor.hidden = false
        
        if let selectedSex = self.person?.sex?.rawValue {
            genderEditor.selectItemWithTitle(selectedSex)
            genderEditor.performClick(self)
        }
    }
    
    @IBAction func editSex(sender: AnyObject) {
        
        guard let popup = sender as? NSPopUpButton else {
            return
        }
        
        if let sex = popup.titleOfSelectedItem, sexItem = Sex(rawValue: sex) {
            self.person?.sex = sexItem
            
            genderLabel.hidden = false
            genderEditor.hidden = true
            
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.person?.tree)

        }
    }
    
    func setParentA() {
        guard let person = self.person else {
            return
        }
        let tree = person.tree
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
        vc.tree = tree
        vc.parentTo = person
        vc.A_B = "A"
        self.presentViewController(vc, asPopoverRelativeToRect: parentsTable.visibleRect, ofView: parentsTable, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
    }
    
    func setParentB() {
        guard let person = self.person else {
            return
        }
        let tree = person.tree
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("AddParentViewController") as! AddParentViewController
        vc.parentTo = person
        vc.tree = tree
        vc.A_B = "B"
        self.presentViewController(vc, asPopoverRelativeToRect: parentsTable.visibleRect, ofView: parentsTable, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Semitransient)
    }
    
    func textDidChange(notification: NSNotification) {
        if let p = self.person, n = notesField.string {
            p.notes = n
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.person?.tree)
        }
    }
    
    //MARK: -
    //MARK: Table Functions
    
    func doubleClick(sender: AnyObject) {
        guard let selectedPerson = self.person, tableView = sender as? NSTableView else {
            return
        }
        
        switch getXcodeTag(tableView.tag) {
        case .ParentsTable:
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.showPerson", object: selectedPerson.parents[parentsTable.selectedRow])
        case .ChildrenTable:
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.showPerson", object: selectedPerson.parents[childrenTable.selectedRow])
        default:
            return
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch getXcodeTag(tableView.tag) {
        case .ParentsTable:
            if let p = self.person {
                return p.parents.count
            } else {
                return 0
            }
        case .ChildrenTable:
            if let p = self.person {
                return p.children.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    /**
     This function manages the table view and and populates it with the necessary values.
     */
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch getXcodeTag(tableView.tag) {
        case .ChildrenTable:
            guard let v = tableView.makeViewWithIdentifier("ChildCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = self.person {
                v.textField?.stringValue = p.children[row].description
            }
            
            return v
        case .ParentsTable:
            guard let v = tableView.makeViewWithIdentifier("ParentCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = self.person {
                v.textField?.stringValue = p.parents[row].description
            }
            
            return v
        default:
            return nil
        }
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
        
    //MARK:-
    
    func removeParentA() {
        if let person = self.person {
            person.parentA = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.person?.tree)
        }
    }
    
    func removeParentB() {
        if let person = self.person {
            person.parentB = nil
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.person?.tree)
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let sender = sender as? NSButton {
            guard let tree = self.person?.tree, let person = self.person else {
                print("People and trees not there")
                return
            }
            if let destination = segue.destinationController as? AddParentViewController {
                destination.tree = tree
                destination.parentTo = person
                if sender.identifier == "addParentA" {
                    destination.A_B = "A"
                } else if sender.identifier == "addParentB" {
                    destination.A_B = "B"
                }
                return
            }
            if let destination = segue.destinationController as? EditNameViewController {
                destination.person = person
                return
            }
            if let destination = segue.destinationController as? BirthdayViewController {
                destination.person = person
                return
            }
            if let destination = segue.destinationController as? DeathViewController {
                destination.person = person
                return
            }
        }
    }
    
    func treeDidUpdate() {
        setupView()
    }
    
    func setupView() {
        guard let person = self.person else {
            print("No person to show")
            return
        }
        
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
        
        if let ezekiel = person.tree.getPerson(givenName: "Ezekiel", familyName: "Elin") {
            deathBirthSublabel.stringValue = ezekiel.relationTo(person: person) ?? deathBirthSublabel.stringValue
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
        
        notesField.string = person.notes
        
        parentsTable.reloadData()
        childrenTable.reloadData()
    }
}