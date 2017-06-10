//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class PersonDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate {
    //MARK: Instance Variables
    @IBOutlet weak var filenameLabel: NSTextField!
    
    @IBOutlet weak var partnersTable: NSTableView!
    @IBOutlet weak var childrenTable: NSTableView!
    
    @IBOutlet weak var profilePhoto: NSImageView!
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var deathBirthSublabel: NSTextField!
    
    @IBOutlet weak var genderLabel: NSTextField!
    @IBOutlet weak var genderEditor: NSPopUpButton!
    
    @IBOutlet weak var birthLabel: NSTextField!
    @IBOutlet weak var deathLabel: NSTextField!
    
    @IBOutlet var notesField: NSTextView!
    
    @IBOutlet weak var setFatherButton: NSButton!
    @IBOutlet weak var removeFatherButton: NSButton!
    @IBOutlet weak var setMotherButton: NSButton!
    @IBOutlet weak var removeMotherButton: NSButton!
    @IBOutlet weak var motherLabel: NSTextField!
    @IBOutlet weak var fatherLabel: NSTextField!
    
    ///The tree
    var person: Person? = nil
    
    //MARK:-
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(treeDidUpdate), name: .FVTreeDidUpdate, object: nil)
        
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
        
        let motherGesture = NSClickGestureRecognizer()
        motherGesture.buttonMask = 0x1 // left mouse
        motherGesture.numberOfClicksRequired = 2
        motherGesture.target = self
        motherGesture.action = #selector(viewMother)
        motherLabel.addGestureRecognizer(motherGesture)
        
        let fatherGesture = NSClickGestureRecognizer()
        fatherGesture.buttonMask = 0x1 // left mouse
        fatherGesture.numberOfClicksRequired = 2
        fatherGesture.target = self
        fatherGesture.action = #selector(viewFather)
        fatherLabel.addGestureRecognizer(fatherGesture)
        
        partnersTable.doubleAction = #selector(doubleClick)
        childrenTable.doubleAction = #selector(doubleClick)
        
        guard let person = self.person else {
            self.dismiss(self)
            return
        }
        
        print("Opening \(person)")
        
        setupView()
    }
    
    //MARK:-
    //MARK: Edit Functions
    
    @objc func editName() {
        if let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditNameViewController")) as? EditNameViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeTo: nameLabel.visibleRect, of: nameLabel, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.semitransient)
        }
    }
    
    @objc func editBirth() {
        if let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "BirthdayViewController")) as? BirthdayViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeTo: birthLabel.visibleRect, of: birthLabel, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.semitransient)
        }
    }
    
    @objc func editDeath() {
        if let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DeathViewController")) as? DeathViewController {
            vc.person = self.person
            self.presentViewController(vc, asPopoverRelativeTo: deathLabel.visibleRect, of: deathLabel, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.semitransient)
        }
    }
    
    @objc func startEditSex() {
        genderLabel.isHidden = true
        genderEditor.isHidden = false
        
        if let selectedSex = self.person?.sex?.rawValue {
            genderEditor.selectItem(withTitle: selectedSex)
            genderEditor.performClick(self)
        }
    }
    
    @IBAction func editSex(_ sender: AnyObject) {
        
        guard let popup = sender as? NSPopUpButton else {
            return
        }
        
        if let sex = popup.titleOfSelectedItem, let sexItem = Sex(rawValue: sex) {
            self.person?.sex = sexItem
            
            genderLabel.isHidden = false
            genderEditor.isHidden = true
            
            NotificationCenter.default.post(name: .FVTreeDidUpdate, object: self.person?.tree)

        }
    }
    
    @IBAction func setMother(_ sender: AnyObject) {
        guard let person = self.person else {
            return
        }
        let tree = person.tree
        
        let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddParentViewController")) as! AddParentViewController
        vc.tree = tree
        vc.parentTo = person
        vc.A_B = "A"
        self.presentViewController(vc, asPopoverRelativeTo: setMotherButton.visibleRect, of: setMotherButton, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.semitransient)
    }
    
    @IBAction func setFather(_ sender: AnyObject) {
        guard let person = self.person else {
            return
        }
        let tree = person.tree
        
        let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddParentViewController")) as! AddParentViewController
        vc.parentTo = person
        vc.tree = tree
        vc.A_B = "B"
        self.presentViewController(vc, asPopoverRelativeTo: setFatherButton.visibleRect, of: setFatherButton, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.semitransient)
    }
    
    func textDidChange(_ notification: Notification) {
        if let p = self.person {
            p.notes = notesField.string
//            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self.person?.tree)
        }
    }
    
    //MARK: -
    //MARK: Table Functions
    
    @objc func doubleClick(_ sender: AnyObject) {
        guard let selectedPerson = self.person, let tableView = sender as? NSTableView else {
            return
        }
        
        switch getXcodeTag(tag: tableView.tag) {
        case .PartnersTable:
            NotificationCenter.default.post(name: .FVShowPerson, object: selectedPerson.partners[partnersTable.selectedRow])
        case .ChildrenTable:
            NotificationCenter.default.post(name: .FVShowPerson, object: selectedPerson.children[childrenTable.selectedRow])
        default:
            return
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch getXcodeTag(tag: tableView.tag) {
        case .PartnersTable:
            if let p = self.person {
                return p.partners.count
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
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch getXcodeTag(tag: tableView.tag) {
        case .ChildrenTable:
            guard let v = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ChildCell"), owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = self.person {
                v.textField?.stringValue = p.children[row].description
            }
            
            return v
        case .PartnersTable:
            guard let v = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PartnerCell"), owner: self) as? NSTableCellView else {
                return nil
            }
            
            if let p = self.person {
                v.textField?.stringValue = p.partners[row].description
            }
            
            return v
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
        
    //MARK:-
    
    @IBAction func removeParentA(_ sender: AnyObject) {
        if let person = self.person {
            person.parentA = nil
            NotificationCenter.default.post(name: .FVTreeDidUpdate, object: self.person?.tree)
        }
    }
    
    @IBAction func removeParentB(_ sender: AnyObject) {
        if let person = self.person {
            person.parentB = nil
            NotificationCenter.default.post(name: .FVTreeDidUpdate, object: self.person?.tree)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let sender = sender as? NSButton {
            guard let tree = self.person?.tree, let person = self.person else {
                print("People and trees not there")
                return
            }
            if let destination = segue.destinationController as? AddParentViewController {
                destination.tree = tree
                destination.parentTo = person
                //TODO: Proper way to do this?
                if sender.identifier?.rawValue == "addParentA" {
                    destination.A_B = "A"
                //TODO: Proper way to do this?
                } else if sender.identifier?.rawValue == "addParentB" {
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
    
    @objc func treeDidUpdate() {
        setupView()
    }
    
    @objc func viewFather() {
        if let father = self.person?.parentB {
            NotificationCenter.default.post(name: .FVShowPerson, object: father)
        }
    }
    
    @objc func viewMother() {
        if let mother = self.person?.parentA {
            NotificationCenter.default.post(name: .FVShowPerson, object: mother)
        }
    }
    
    @IBAction func deletePerson(_ sender: AnyObject) {
        guard let person = self.person else {
            return
        }
        let alert = NSAlert()
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Delete \(person.description)?"
        alert.informativeText = "This cannot be undone"
        alert.alertStyle = .critical
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            self.person = nil
            let _ = person.tree.removePerson(p: person)
        } else {
            print("Cancel")
        }
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
            if person.death.dateOfDeath.isSet() {
                deathString = person.death.dateOfDeath.description
            } else {
                deathString = "Unknown"
            }
            deathBirthSublabel.stringValue = "\(birthString) - \(deathString)"
        }
        
        if let ezekiel = person.tree.getPerson(givenName: "Ezekiel", familyName: "Elin") {
            deathBirthSublabel.stringValue = ezekiel.relationTo(person: person) ?? deathBirthSublabel.stringValue
        }
        
        person.describe()
        
        
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
        } else if person.death.dateOfDeath.isSet() {
            deathLabel.stringValue = person.death.dateOfDeath.description
        } else if !person.death.locationOfDeath.isEmpty {
            deathLabel.stringValue = person.death.locationOfDeath
        } else {
            deathLabel.stringValue = "Date Unknown"
        }
        
        if let mother = person.parentA {
            self.motherLabel.stringValue = mother.description
            self.motherLabel.isHidden = false
            self.setMotherButton.isHidden = true
            self.removeMotherButton.isHidden = false
        } else {
            self.motherLabel.isHidden = true
            self.setMotherButton.isHidden = false
            self.removeMotherButton.isHidden = true
        }
        
        if let father = person.parentB {
            self.fatherLabel.stringValue = father.description
            self.fatherLabel.isHidden = false
            self.setFatherButton.isHidden = true
            self.removeFatherButton.isHidden = false
        } else {
            self.fatherLabel.isHidden = true
            self.setFatherButton.isHidden = false
            self.removeFatherButton.isHidden = true
        }
        
        print(person.mostProbableSpouse ?? "No spouse returned")
        
        notesField.string = person.notes
        
        partnersTable.reloadData()
        childrenTable.reloadData()
    }
}
