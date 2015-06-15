//
//  ViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var lastNameField: NSTextField!
    @IBOutlet weak var firstNameField: NSTextField!
    @IBOutlet weak var spouseRadio: NSButton!
    @IBOutlet weak var childRadio: NSButton!
    
    @IBOutlet weak var husbandLabel: NSTextField!
    @IBOutlet weak var wifeLabel: NSTextField!
    @IBOutlet weak var childrenLabel: NSTextField!
    
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var noDataLabel: NSTextField!
    @IBOutlet weak var notFoundLabel: NSTextField!
    @IBAction func spouseRadio(sender: AnyObject) {
        defer {
            self.updateButton(sender)
        }
        
        childRadio.stringValue = "0"
    }
    @IBAction func childRadio(sender: AnyObject) {
        defer {
            self.updateButton(sender)
        }
        
        spouseRadio.stringValue = "0"
    }

    @IBAction func updateButton(sender: AnyObject) {
        guard let t = self.representedObject as? Tree else {
            noData()
            return
        }
        print(t)
        var family: Family? = nil
        for p in t.people {
            if p.name.givenName == firstNameField.stringValue && p.name.familyName == lastNameField.stringValue {
                for f in t.families {
                    if spouseRadio.stringValue == "1" && (f.husband?.INDI == p.INDI || f.wife?.INDI == p.INDI) {
                        family = f
                    } else if childRadio.stringValue == "1" {
                        for c in f.children {
                            if c.INDI == p.INDI {
                                family = f
                            }
                        }
                    }
                }
            }
        }
        guard let f = family else {
            husbandLabel.hidden = true
            wifeLabel.hidden = true
            childrenLabel.hidden = true
            notFoundLabel.hidden = false
            return
        }
        husbandLabel.hidden = false
        wifeLabel.hidden = false
        childrenLabel.hidden = false
        notFoundLabel.hidden = true
        husbandLabel.stringValue = f.husband!.description
        wifeLabel.stringValue = f.wife!.description
        childrenLabel.stringValue = f.children.description
        
        if t.people.count == 0 {
            noData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = representedObject as? Tree else {
            noData()
            return
        }
        // Do any additional setup after loading the view.
    }

    func noData() {
        return
        husbandLabel.hidden = true
        wifeLabel.hidden = true
        childrenLabel.hidden = true
        firstNameField.hidden = true
        lastNameField.hidden = true
        spouseRadio.hidden = true
        childRadio.hidden = true
        notFoundLabel.hidden = true
        noDataLabel.hidden = false
        updateButton.hidden = true
    }
    
    override var representedObject: AnyObject? {
        didSet {
            guard let tree = representedObject as? Tree else {
                representedObject = nil
                noData()
                return
            }
            for f in tree.families {
                print(f)
            }
            print(tree.people.count)
        }
    }
}

