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
    var families = [Family]()
    
    func getPersonByID(id id: Int) -> Person? {
        for p in self.people {
            if p.INDI == id {
                return p
            }
        }
        return nil
    }
}

enum Sex {
    case Male, Female, Unknown
}

enum FamilyType {
    case Married, Engaged, Relationship, Seperated, Divorced, Annulled
}

///Represents a family
class Family {
    var FAM: Int?
    var husband: Person?
    var wife: Person?
    var children = [Person]()
    var type: FamilyType?
    
    init(gedcomEntity ge: [String], tree t: Tree) {
        for row in ge {
            if row.rangeOfString("FAM") != nil {
                self.FAM = Int(row.stringByReplacingOccurrencesOfString("0 @F", withString: "").stringByReplacingOccurrencesOfString("@ FAM", withString: ""))!
            } else if row.rangeOfString("HUSB") != nil {
                let husbandID = Int(row.stringByReplacingOccurrencesOfString("1 HUSB @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                self.husband = t.getPersonByID(id: husbandID)
            } else if row.rangeOfString("WIFE") != nil {
                let wifeID = Int(row.stringByReplacingOccurrencesOfString("1 WIFE @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                self.wife = t.getPersonByID(id: wifeID)
            } else if row.rangeOfString("CHIL") != nil {
                let childID = Int(row.stringByReplacingOccurrencesOfString("1 CHIL @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                self.children.append(t.getPersonByID(id: childID))
            } else if row.rangeOfString("MARR") != nil {
                self.type = FamilyType.Married
            }
        }
    }
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
    let tree = Tree()
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
            tree.people.append(p)
        }
    }
    for entity in firstLevelObjects {
        if entity[0].rangeOfString("FAM") != nil {
            let f = Family(gedcomEntity: entity, tree: tree)
            tree.families.append(f)
        }
    }
    
    return tree
}