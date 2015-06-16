//
//  EditNameViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/16/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

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
    @IBOutlet weak var secondNickNameEnabled: NSButton!
    
    @IBOutlet weak var secondPrefixField: NSTextField!
    @IBOutlet weak var secondGivenNameField: NSTextField!
    @IBOutlet weak var secondMiddleNameField: NSTextField!
    @IBOutlet weak var secondFamilyNameField: NSTextField!
    @IBOutlet weak var secondSuffixField: NSTextField!
    @IBOutlet weak var secondNickNameField: NSTextField!
    
    var person: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let person = person else {
            assert(false, "Unexpectedly found nil for person:Person?")
            return
        }
        
        if person.nameAtBirth.namePrefix != "##blank##" {
            self.prefixAtBirthField.stringValue = person.nameAtBirth.namePrefix
        }
        if person.nameAtBirth.givenName != "##blank##" {
            self.givenNameAtBirthField.stringValue = person.nameAtBirth.givenName
        }
        if person.nameAtBirth.middleName != "##blank##" {
            self.middleNameAtBirthField.stringValue = person.nameAtBirth.middleName
        }
        if person.nameAtBirth.familyName != "##blank##" {
            self.familyNameAtBirthField.stringValue = person.nameAtBirth.familyName
        }
        if person.nameAtBirth.nameSuffix != "##blank##" {
            self.suffixAtBirthField.stringValue = person.nameAtBirth.nameSuffix
        }
        if person.nameAtBirth.nickname != "##blank##" {
            self.nicknameAtBirthField.stringValue = person.nameAtBirth.nickname
        }
        
        if person.nameNow.namePrefix != "" && person.nameNow.namePrefix != person.nameAtBirth.namePrefix {
            self.secondPrefixEnabled.isChecked = true
            if person.nameNow.namePrefix != "##blank##" {
                self.secondPrefixField.stringValue = person.nameNow.namePrefix
            }
        }
        if person.nameNow.givenName != "" && person.nameNow.givenName != person.nameAtBirth.givenName {
            self.secondGivenNameEnabled.isChecked = true
            if person.nameNow.givenName != "##blank##" {
                self.secondGivenNameField.stringValue = person.nameNow.givenName
            }
        }
        if person.nameNow.middleName != "" && person.nameNow.middleName != person.nameAtBirth.middleName {
            self.secondMiddleNameEnalbed.isChecked = true
            if person.nameNow.middleName != "##blank##" {
                self.secondMiddleNameField.stringValue = person.nameNow.middleName
            }
        }
        if person.nameNow.familyName != "" && person.nameNow.familyName != person.nameAtBirth.familyName {
            self.secondFamilyNameEnabled.isChecked = true
            if person.nameNow.familyName != "##blank##" {
                self.secondFamilyNameField.stringValue = person.nameNow.familyName
            }
        }
        if person.nameNow.nameSuffix != "" && person.nameNow.nameSuffix != person.nameAtBirth.nameSuffix {
            self.secondSuffixEnabled.isChecked = true
            if person.nameNow.nameSuffix != "##blank##" {
                self.secondSuffixField.stringValue = person.nameNow.nameSuffix
            }
        }
        if person.nameNow.nickname != "" && person.nameNow.nickname != person.nameAtBirth.nickname {
            self.secondNickNameEnabled.isChecked = true
            if person.nameNow.nickname != "##blank##" {
                self.secondNickNameField.stringValue = person.nameNow.nickname
            }
        }
    }
    
    @IBAction func updateSecondFields(sender: AnyObject) {
        secondPrefixField.enabled = secondPrefixEnabled.isChecked
        secondGivenNameField.enabled = secondGivenNameEnabled.isChecked
        secondMiddleNameField.enabled = secondMiddleNameEnalbed.isChecked
        secondFamilyNameField.enabled = secondFamilyNameEnabled.isChecked
        secondSuffixField.enabled = secondSuffixEnabled.isChecked
        secondNickNameField.enabled = secondNickNameEnabled.isChecked
        
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
        
        if let person = person {
            if self.prefixAtBirthField.stringValue == "" {
                person.nameAtBirth.namePrefix = "##blank##"
            } else {
                person.nameAtBirth.namePrefix = self.prefixAtBirthField.stringValue
            }
            if self.givenNameAtBirthField.stringValue == "" {
                person.nameAtBirth.givenName = "##blank##"
            } else {
                person.nameAtBirth.givenName = self.givenNameAtBirthField.stringValue
            }
            if self.middleNameAtBirthField.stringValue == "" {
                person.nameAtBirth.middleName = "##blank##"
            } else {
                person.nameAtBirth.middleName = self.middleNameAtBirthField.stringValue
            }
            if self.familyNameAtBirthField.stringValue == "" {
                person.nameAtBirth.familyName = "##blank##"
            } else {
                person.nameAtBirth.familyName = self.familyNameAtBirthField.stringValue
            }
            if self.suffixAtBirthField.stringValue == "" {
                person.nameAtBirth.nameSuffix = "##blank##"
            } else {
                person.nameAtBirth.nameSuffix = self.suffixAtBirthField.stringValue
            }
            if self.nicknameAtBirthField.stringValue == "" {
                person.nameAtBirth.nickname = "##blank##"
            } else {
                person.nameAtBirth.nickname = self.nicknameAtBirthField.stringValue
            }
            
            if self.secondPrefixField.stringValue == "" && self.secondPrefixEnabled.isChecked {
                person.nameNow.namePrefix = "##blank##"
            } else {
                person.nameNow.namePrefix = self.secondPrefixField.stringValue
            }
            if self.secondGivenNameField.stringValue == "" && self.secondGivenNameEnabled.isChecked {
                person.nameNow.givenName = "##blank##"
            } else {
                person.nameNow.givenName = self.secondGivenNameField.stringValue
            }
            if self.secondMiddleNameField.stringValue == "" && self.secondMiddleNameEnalbed.isChecked {
                person.nameNow.middleName = "##blank##"
            } else {
                person.nameNow.middleName = self.secondMiddleNameField.stringValue
            }
            if self.secondFamilyNameField.stringValue == "" && self.secondFamilyNameEnabled.isChecked {
                person.nameNow.familyName = "##blank##"
            } else {
                person.nameNow.familyName = self.secondFamilyNameField.stringValue
            }
            if self.secondSuffixField.stringValue == "" && self.secondSuffixEnabled.isChecked {
                person.nameNow.nameSuffix = "##blank##"
            } else {
                person.nameNow.nameSuffix = self.secondSuffixField.stringValue
            }
            if self.secondNickNameField.stringValue == "" && self.secondNickNameEnabled.isChecked {
                person.nameNow.nickname = "##blank##"
            } else {
                person.nameNow.nickname = self.secondNickNameField.stringValue
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        }
    }
}
