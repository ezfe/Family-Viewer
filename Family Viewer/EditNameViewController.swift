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
    @IBOutlet weak var secondMiddleNameEnabled: NSButton!
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
            return
        }
        
        if let namePrefix = person.nameAtBirth.namePrefix {
            self.prefixAtBirthField.stringValue = namePrefix
        }
        if let givenName = person.nameAtBirth.givenName {
            self.givenNameAtBirthField.stringValue = givenName
        }
        if let middleName = person.nameAtBirth.middleName {
            self.middleNameAtBirthField.stringValue = middleName
        }
        if let familyName = person.nameAtBirth.familyName {
            self.familyNameAtBirthField.stringValue = familyName
        }
        if let nameSuffix = person.nameAtBirth.nameSuffix {
            self.suffixAtBirthField.stringValue = nameSuffix
        }
        if let nickname = person.nameAtBirth.nickname {
            self.nicknameAtBirthField.stringValue = nickname
        }
        
        if let namePrefix = person.nameNow.namePrefix, person.nameNow.namePrefix != person.nameAtBirth.namePrefix {
            self.secondPrefixEnabled.isChecked = true
            self.secondPrefixField.stringValue = namePrefix
        }
        if let givenName = person.nameNow.givenName, person.nameNow.givenName != person.nameAtBirth.givenName {
            self.secondGivenNameEnabled.isChecked = true
            self.secondGivenNameField.stringValue = givenName
        }
        if let middleName = person.nameNow.middleName, person.nameNow.middleName != person.nameAtBirth.middleName {
            self.secondMiddleNameEnabled.isChecked = true
            self.secondMiddleNameField.stringValue = middleName
        }
        if let familyName = person.nameNow.familyName, person.nameNow.familyName != person.nameAtBirth.familyName {
            self.secondFamilyNameEnabled.isChecked = true
            self.secondFamilyNameField.stringValue = familyName
        }
        if let nameSuffix = person.nameNow.nameSuffix, person.nameNow.nameSuffix != person.nameAtBirth.nameSuffix {
            self.secondSuffixEnabled.isChecked = true
            self.secondSuffixField.stringValue = nameSuffix
        }
        if let nickname = person.nameNow.nickname, person.nameNow.nickname != person.nameAtBirth.nickname {
            self.secondNickNameEnabled.isChecked = true
            self.secondNickNameField.stringValue = nickname
        }
    }
    
    @IBAction func updateSecondFields(_ sender: AnyObject) {
        secondPrefixField.isEnabled = secondPrefixEnabled.isChecked
        secondGivenNameField.isEnabled = secondGivenNameEnabled.isChecked
        secondMiddleNameField.isEnabled = secondMiddleNameEnabled.isChecked
        secondFamilyNameField.isEnabled = secondFamilyNameEnabled.isChecked
        secondSuffixField.isEnabled = secondSuffixEnabled.isChecked
        secondNickNameField.isEnabled = secondNickNameEnabled.isChecked
        
        if !secondPrefixEnabled.isChecked {
            secondPrefixField.stringValue = prefixAtBirthField.stringValue
        }
        if !secondGivenNameEnabled.isChecked {
            secondGivenNameField.stringValue = givenNameAtBirthField.stringValue
        }
        if !secondMiddleNameEnabled.isChecked {
            secondMiddleNameField.stringValue = middleNameAtBirthField.stringValue
        }
        if !secondFamilyNameEnabled.isChecked {
            secondFamilyNameField.stringValue = familyNameAtBirthField.stringValue
        }
        if !secondSuffixEnabled.isChecked {
            secondSuffixField.stringValue = suffixAtBirthField.stringValue
        }
        if !secondNickNameEnabled.isChecked {
            secondNickNameField.stringValue = nicknameAtBirthField.stringValue
        }
        
        if let person = person {
            person.nameAtBirth.namePrefix = (self.prefixAtBirthField.stringValue == "" ? nil : self.prefixAtBirthField.stringValue)
            person.nameAtBirth.givenName = (self.givenNameAtBirthField.stringValue == "" ? nil : self.givenNameAtBirthField.stringValue)
            person.nameAtBirth.middleName = (self.middleNameAtBirthField.stringValue == "" ? nil : self.middleNameAtBirthField.stringValue)
            person.nameAtBirth.familyName = (self.familyNameAtBirthField.stringValue == "" ? nil : self.familyNameAtBirthField.stringValue)
            person.nameAtBirth.nameSuffix = (self.suffixAtBirthField.stringValue == "" ? nil : self.suffixAtBirthField.stringValue)
            person.nameAtBirth.nickname = (self.nicknameAtBirthField.stringValue == "" ? nil : nicknameAtBirthField.stringValue)
            
            if self.secondPrefixEnabled.isChecked {
                person.nameNow.namePrefix = self.secondPrefixField.stringValue
            } else {
                person.nameNow.namePrefix = nil
            }
            if self.secondGivenNameEnabled.isChecked {
                person.nameNow.givenName = self.secondGivenNameField.stringValue
            } else {
                person.nameNow.givenName = nil
            }
            if self.secondMiddleNameEnabled.isChecked {
                person.nameNow.middleName = self.secondMiddleNameField.stringValue
            } else {
                person.nameNow.middleName = nil
            }
            
            if self.secondFamilyNameEnabled.isChecked {
                person.nameNow.familyName = self.secondFamilyNameField.stringValue
            } else {
                person.nameNow.familyName = nil
            }
            if self.secondSuffixEnabled.isChecked {
                person.nameNow.nameSuffix = self.secondSuffixField.stringValue
            } else {
                person.nameNow.nameSuffix = nil
            }
            if self.secondNickNameEnabled.isChecked {
                person.nameNow.nickname = self.secondNickNameField.stringValue
            } else {
                person.nameNow.nickname = nil
            }
            
            NotificationCenter.default.post(name: .FVTreeDidUpdate, object: nil)
        } else {
            self.dismiss(self)
        }
    }
}
