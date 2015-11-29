//
//  Person.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 9/5/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation

class Person: CustomStringConvertible {
    ///Name String
    var description: String {
        get {
            let ret = self.getNameNow().isSet() ? self.getNameNow().description : "Person"
            return "\(ret) \(INDI)"
        }
    }
    ///Name components
    var nameNow = NameComponents()
    ///Maiden name
    var nameAtBirth = NameComponents()
    
    ///Get a NameComponents for their current name, filling in blanks with nameAtBirth
    func getNameNow() -> NameComponents {
        let nameNow = self.nameNow
        if nameNow.namePrefix == nil {
            nameNow.namePrefix = nameAtBirth.namePrefix
        }
        if nameNow.givenName == nil {
            nameNow.givenName = nameAtBirth.givenName
        }
        if nameNow.middleName == nil {
            nameNow.middleName = nameAtBirth.middleName
        }
        if nameNow.familyName == nil {
            nameNow.familyName = nameAtBirth.familyName
        }
        if nameNow.namePrefix == nil {
            nameNow.namePrefix = nameAtBirth.namePrefix
        }
        if nameNow.nickname == nil {
            nameNow.nickname = nameAtBirth.nickname
        }
        return nameNow
    }
    
    ///INDI Code, not including preceding @I and trailing @
    var INDI: Int
    ///Birth
    var birth = Birth()
    ///Is ``self`` alive
    var isAlive: Bool {
        get {
            //Gets the value from the death object
            return !self.death.hasDied
        }
        set (isAlive) {
            //Stores the value in the death object
            self.death.hasDied = !isAlive
        }
    }
    
    
    var death = Death()
    var sex: Sex?
    
    ///Parent A (Usually Mother)
    var parentA: Person?
    ///Parent B (Usually Father)
    var parentB: Person?
    
    var tree: Tree
    
    var children: [Person] {
        get {
            var to_return = [Person]()
            for p in self.tree.people {
                if p.parentA == self || p.parentB == self {
                    to_return.append(p)
                }
            }
            return to_return
        }
    }

    ///List of siblings that share at least one parent (includes half siblings)
    var allSiblings: [Person] {
        get {
            var to_return = [Person]()
            for p in self.tree.people {
                if p == self {
                    continue
                }
                if p.parentA == self.parentA || p.parentA == self.parentB {
                    to_return.append(p)
                } else if p.parentB == self.parentA || p.parentB == self.parentB {
                    to_return.append(p)
                }
            }
            return to_return
        }
    }
    
    ///List of siblings that share both parents
    var fullSiblings: [Person] {
        get {
            var to_return = [Person]()
            for p in self.tree.people {
                if p == self {
                    continue
                }
                if (p.parentA! == self.parentA! || p.parentA! == self.parentB!) && (p.parentB! == self.parentA! || p.parentB! == self.parentB!) {
                    to_return.append(p)
                }
            }
            return to_return
        }
    }
    
    func cleanupAssociationsForDeletion() {
        for c in self.children {
            if c.parentA == self {
                c.parentA = nil
            }
            if c.parentB == self {
                c.parentB = nil
            }
        }
    }
    
    init(tree t: Tree) {
        self.tree = t
        self.INDI = tree.getUniqueINDI()
        //TODO: Better solution than storing male by default
        self.sex = Sex.Male
    }
    
    init(gedcomEntity ge: [String], tree t: Tree) {
        self.tree = t
        self.INDI = tree.getUniqueINDI()
        for (i,row) in ge.enumerate() {
            if row.rangeOfString("INDI") != nil {
                self.INDI = Int(row.stringByReplacingOccurrencesOfString("0 @I", withString: "").stringByReplacingOccurrencesOfString("@ INDI", withString: ""))!
            } else if row.rangeOfString("NAME") != nil {
                for (x,row) in ge.enumerate() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.rangeOfString("GIVN") != nil {
                        let givenName = row.stringByReplacingOccurrencesOfString("2 GIVN ", withString: "")
                        self.nameAtBirth.givenName = givenName
                    } else if row.rangeOfString("_MARNM") != nil {
                        self.nameNow.familyName = row.stringByReplacingOccurrencesOfString("2 _MARNM ", withString: "")
                    } else if row.rangeOfString("SURN") != nil {
                        self.nameAtBirth.familyName = row.stringByReplacingOccurrencesOfString("2 SURN ", withString: "")
                    }
                }
            } else if row.rangeOfString("BIRT") != nil {
                for (x,row) in ge.enumerate() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.rangeOfString("DATE") != nil {
                        let dateString = row.stringByReplacingOccurrencesOfString("2 DATE ", withString: "")
                        self.birth.date = convertFEDate(date: dateString)
                    } else if row.rangeOfString("PLAC") != nil {
                        //                        let placeString = row.stringByReplacingOccurrencesOfString("2 PLAC ", withString: "")
                        //                        Don't parse location for now, just have that entered later in UI
                        
                    }
                }
            } else if row.rangeOfString("DEAT Y") != nil {
                self.isAlive = false
                for (x,row) in ge.enumerate() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.rangeOfString("DATE") != nil {
                        let dateString = row.stringByReplacingOccurrencesOfString("2 DATE ", withString: "")
                        self.death.date = convertFEDate(date: dateString)
                    } else if row.rangeOfString("PLAC") != nil {
                        //                        let placeString = row.stringByReplacingOccurrencesOfString("2 PLAC ", withString: "")
                        //                        Don't parse location for now, just have that entered later in UI
                    }
                }
            } else if row.rangeOfString("SEX") != nil {
                switch row.stringByReplacingOccurrencesOfString("1 SEX ", withString: "") {
                case "M":
                    self.sex = Sex.Male
                case "F":
                    self.sex = Sex.Female
                default:
                    self.sex = nil
                }
            }
            
            if self.nameNow.givenName == "" && self.nameAtBirth.givenName != "" {
                self.nameNow.givenName = self.nameAtBirth.givenName
            } else if self.nameAtBirth.givenName == "" && self.nameNow.givenName != "" {
                self.nameAtBirth.givenName = self.nameNow.givenName
            }
        }
    }
    
    ///Dictionary representation
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            
            dict["nameNow"] = self.nameNow.dictionary
            dict["nameAtBirth"] = self.nameAtBirth.dictionary
            dict["INDI"] = self.INDI
            dict["birth"] = self.birth.dictionary
            dict["death"] = self.death.dictionary
            dict["sex"] = self.sex!.rawValue
            if let pA = self.parentA {
                dict["parentA"] = pA.INDI
            }
            if let pB = self.parentB {
                dict["parentB"] = pB.INDI
            }
            
            return dict
        }
    }
}
