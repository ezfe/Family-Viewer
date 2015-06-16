//
//  EditNameViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/16/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

extension NSButton {
    var isChecked: Bool {
        get {
            return (self.stringValue == "1")
        }
    }
}

class EditNameViewController: NSViewController {

    @IBOutlet weak var prefixAtBirthField: NSTextField!
    @IBOutlet weak var givenNameAtBirthField: NSTextField!
    @IBOutlet weak var middleNameAtBirthField: NSTextField!
    @IBOutlet weak var familyNameAtBirthField: NSTextField!
    @IBOutlet weak var suffixAtBirthField: NSTextField!
    @IBOutlet weak var nicknameAtBirthField: NSTextField!
    
    @IBOutlet weak var secondPrefixEnabled: NSButton!
    @IBOutlet weak var secondGivenNameEnabled: NSButton!
    @IBOutlet weak var secondMiddleNameEnalbed: NSButton!
    @IBOutlet weak var secondFamilyNameEnabled: NSButton!
    @IBOutlet weak var secondSuffixEnabled: NSButton!
    @IBOutlet weak var secondNicknameEnabled: NSButton!
    
    @IBOutlet weak var secondPrefixField: NSTextField!
    @IBOutlet weak var secondGivenNameField: NSTextField!
    @IBOutlet weak var secondMiddleNameField: NSTextField!
    @IBOutlet weak var secondFamilyNameField: NSTextField!
    @IBOutlet weak var secondSuffixField: NSTextField!
    @IBOutlet weak var secondNickNameField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func updateSecondFields(sender: AnyObject) {
        secondPrefixField.enabled = secondPrefixEnabled.isChecked
        secondGivenNameField.enabled = secondGivenNameEnabled.isChecked
        secondMiddleNameField.enabled = secondMiddleNameEnalbed.isChecked
        secondFamilyNameField.enabled = secondFamilyNameEnabled.isChecked
        secondSuffixField.enabled = secondSuffixEnabled.isChecked
        secondNickNameField.enabled = secondNicknameEnabled.isChecked
        
        if !secondPrefixEnabled.isChecked {
            secondPrefixField.stringValue = prefixAtBirthField.stringValue
        }
        if !secondGivenNameEnabled.isChecked {
            secondGivenNameField.stringValue = givenNameAtBirthField.stringValue
        }
        if !secondMiddleNameEnalbed.isChecked {
            secondMiddleNameField.stringValue = middleNameAtBirthField.stringValue
        }
        if !secondFamilyNameEnabled.isChecked {
            secondFamilyNameField.stringValue = familyNameAtBirthField.stringValue
        }
        if !secondSuffixEnabled.isChecked {
            secondSuffixField.stringValue = suffixAtBirthField.stringValue
        }
        if !secondPrefixEnabled.isChecked {
            secondNickNameField.stringValue = nicknameAtBirthField.stringValue
        }
    }
}
