//
//  Utility.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

///Represents the entire tree
class Tree {
    var people = [Person]()
}

enum Sex {
    case Male, Female, Unknown
}

enum FamilyType {
    case Married, Engaged, Relationship, Seperated, Divorced, Annulled
}

///Represents a family
class Family {
    var husband: Person?
    var wife: Person?
    var children = [Person]()
    var type: FamilyType?
}

///Represents a person in the family
class Person: CustomStringConvertible {
    ///Name components
    var name: NSPersonNameComponents
    ///Maiden name
    var givenFamilyName: String?
    ///INDI Code, not including preceding @I and trailing @
    var INDI: Int?
    ///Day Born
    var birthDay: String?
    ///Birth Location
    var birthLocation: String?
    ///Alive
    var isAlive: Bool = true
    ///Day Died
    var deathDay: String?
    ///Death Location
    var deathLocation: String?
    ///Sex
    var sex: Sex = Sex.Unknown
    
    init(gedcomEntity ge: [String]) {
        self.name = NSPersonNameComponents()
        
        for (i,row) in ge.enumerate() {
            if row.rangeOfString("INDI") != nil {
                self.INDI = Int(row.stringByReplacingOccurrencesOfString("0 @I", withString: "").stringByReplacingOccurrencesOfString("@ INDI", withString: ""))!
                print(self.INDI!)
            } else if row.rangeOfString("NAME") != nil {
                for (x,row) in ge.enumerate() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.rangeOfString("GIVN") != nil {
                        self.name.givenName = row.stringByReplacingOccurrencesOfString("2 GIVN ", withString: "")
                    } else if row.rangeOfString("_MARNM") != nil {
                        self.name.familyName = row.stringByReplacingOccurrencesOfString("2 _MARNM ", withString: "")
                    } else if row.rangeOfString("SURN") != nil {
                        self.givenFamilyName = row.stringByReplacingOccurrencesOfString("2 SURN ", withString: "")
                    }
                }
                if self.givenFamilyName == self.name.familyName {
                    self.givenFamilyName = nil
                }
            } else if row.rangeOfString("BIRT") != nil {
                for (x,row) in ge.enumerate() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.rangeOfString("DATE") != nil {
                        let dateString = row.stringByReplacingOccurrencesOfString("2 DATE ", withString: "")
                        self.birthDay = dateString
                    } else if row.rangeOfString("PLAC") != nil {
                        self.birthLocation = row.stringByReplacingOccurrencesOfString("2 PLAC ", withString: "")
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
                        self.deathDay = dateString
                    } else if row.rangeOfString("PLAC") != nil {
                        self.deathLocation = row.stringByReplacingOccurrencesOfString("2 PLAC ", withString: "")
                    }
                }
            } else if row.rangeOfString("SEX") != nil {
                switch row.stringByReplacingOccurrencesOfString("1 SEX ", withString: "") {
                case "M":
                    self.sex = .Male
                case "F":
                    self.sex = .Female
                default:
                    self.sex = .Unknown
                }
            }
        }
        print(self)
    }
    
    var description: String {
        get {
            if let givenFamilyName = self.givenFamilyName {
                return "\(self.name.givenName) (\(givenFamilyName)) \(self.name.familyName)"
            } else {
                return "\(self.name.givenName) \(self.name.familyName)"
            }
        }
    }
}

func GEDCOMToFamilyObject(gedcomString inputData: String) -> Tree {
    let family = Tree()
    var rows = (inputData.componentsSeparatedByString("\n"))
    rows.removeLast()
    if (rows[0][0] != "0") {
        assert(false, "First row isn't Level:0")
    }
    for (i,row) in rows.enumerate() {
        if (row.characters.count == 0) {
            assert(false, "Empty row!")
        }
        rows[i] = row.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    var firstLevelObjects = [[String]]()
    var workingEntity = [String]()
    
    for (i,row) in rows.enumerate() {
        let rowLevel = Int(row[0])!
        if i != 0 && rowLevel == 0 {
            firstLevelObjects.append(workingEntity)
            workingEntity = [String]()
        }
        workingEntity.append(row)
    }
    
    for entity in firstLevelObjects {
        if entity[0].rangeOfString("INDI") != nil {
            let p = Person(gedcomEntity: entity)
            family.people.append(p)
        }
    }
    
    return family
}