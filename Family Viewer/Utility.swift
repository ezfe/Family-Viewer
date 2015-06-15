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
class Tree: CustomStringConvertible {
    ///List of Person objects in the tree
    var people = [Person]()
    
    ///List of Person objects in ID:Description format
    var indexOfPeople: [String] {
        get {
            var to_return = [String]()
            for p in people {
                to_return.append(p.description)
            }
            return to_return
        }
    }
    
    ///Get a person based on their ID
    func getPerson(id id: Int) -> Person? {
        for p in self.people {
            if p.INDI == id {
                return p
            }
        }
        return nil
    }
    
    ///Get a person by their name, e.g. Kezia Lind, Kezia Sørbøe
    func getPerson(givenName firstName: String, familyName lastName: String) -> Person? {
        for p in self.people {
            if p.nameNow.givenName.lowercaseString == firstName.lowercaseString && p.nameNow.familyName.lowercaseString == lastName.lowercaseString {
                return p
            }
            if p.nameAtBirth.givenName.lowercaseString == firstName.lowercaseString && p.nameAtBirth.familyName.lowercaseString == lastName.lowercaseString {
                return p
            }
        }
        return nil
    }
    
    ///Description of the tree
    var description: String {
        get {
            return "Tree with \(people.count) people"
        }
    }
    
    ///NSMutableArray representation
    var dictionary: NSMutableArray {
        get {
            let dict = NSMutableArray()
            for person in people {
                dict.addObject(person.dictionary)
            }
            return dict
        }
    }
}

enum Sex: String {
    case Male = "Male"
    case Female = "Female"
}

enum FamilyType {
    case Married, Engaged, Relationship, Seperated, Divorced, Annulled
}

enum Month: Int {
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
}

enum USState: String {
    case Alabama = "Alabama"
    case Alaska = "Alaska"
    case Arizona = "Arizona"
    case Arkansas = "Arkansas"
    case California = "California"
    case Colorado = "Colorado"
    case Connecticut = "Connecticut"
    case Delaware = "Delaware"
    case Florida = "Florida"
    case Georgia = "Georgia"
    case Hawaii = "Hawaii"
    case Idaho = "Idaho"
    case Illinois = "Illinois"
    case Indiana = "Indiana"
    case Iowa = "Iowa"
    case Kansas = "Kansas"
    case Kentucky = "Kentucky"
    case Louisiana = "Louisiana"
    case Maine = "Maine"
    case Maryland = "Maryland"
    case Massachusetts = "Massachusetts"
    case Michigan = "Michigan"
    case Minnesota = "Minnesota"
    case Mississippi = "Mississippi"
    case Missouri = "Missouri"
    case Montana = "Montana"
    case Nebraska = "Nebraska"
    case Nevada = "Nevada"
    case New_Hampshire = "New Hampshire"
    case New_Jersey = "New Jersey"
    case New_Mexico = "New Mexico"
    case New_York = "New York"
    case North_Carolina = "North Carolina"
    case North_Dakota = "North Dakota"
    case Ohio = "Ohio"
    case Oklahoma = "Oklahoma"
    case Oregon = "Oregon"
    case Pennsylvania = "Pennsylvania"
    case Rhode_Island = "Rhode Island"
    case South_Carolina = "South Carolina"
    case South_Dakota = "South Dakota"
    case Tennessee = "Tennessee"
    case Texas = "Texas"
    case Utah = "Utah"
    case Vermont = "Vermont"
    case Virginia = "Virginia"
    case Washington = "Washington"
    case West_Virginia = "West Virginia"
    case Wisconsin = "Wisconsin"
    case Wyoming = "Wyoming"
}

struct Date {
    var day: Int? = nil
    var month: Month? = nil
    var year: Int? = nil
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            if let day = day {
                dict["day"] = day
            }
            if let month = month {
                dict["day"] = month.rawValue
            }
            if let year = year {
                dict["day"] = year
            }
            return dict
        }
    }
}

struct Place {
    var road: String?
    var city: String?
    var state: USState?
    var zip: String?
    var country: String?
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            if let road = road {
                dict["road"] = road
            }
            if let city = city {
                dict["city"] = city
            }
            if let state = state {
                dict["state"] = state.rawValue
            }
            if let zip = zip {
                dict["zip"] = zip
            }
            if let country = country {
                dict["country"] = country
            }
            return dict
        }
    }
}

struct Birth {
    var date: Date = Date(day: nil, month: nil, year: nil)
    var location: Place = Place(road: nil, city: nil, state: nil, zip: nil, country: nil)
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            dict["date"] = date.dictionary
            dict["location"] = location.dictionary
            return dict
        }
    }
}

struct Death {
    ///Has died
    var hasDied = false
    ///Date of death
    var date: Date = Date(day: nil, month: nil, year: nil)
    ///Place of death
    var location: Place = Place(road: nil, city: nil, state: nil, zip: nil, country: nil)

    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            dict["date"] = date.dictionary
            dict["location"] = location.dictionary
            dict["hasDied"] = hasDied
            return dict
        }
    }
}

///Converts DD MMM YYYY to Date() object
func convertFEDate(date d: String) -> Date {
    return Date(day: nil, month: nil, year: nil)
}

///Represents a person in the family
class Person: CustomStringConvertible {
    ///Name String
    var description: String {
        get {
            if self.nameAtBirth.familyName != self.nameNow.familyName {
                return "\(self.nameNow.givenName) (\(self.nameAtBirth.familyName)) \(self.nameNow.familyName)"
            } else {
                return "\(self.nameNow.givenName) \(self.nameNow.familyName)"
            }
        }
    }
    ///Name components
    var nameNow = NSPersonNameComponents()
    ///Maiden name
    var nameAtBirth = NSPersonNameComponents()
    ///INDI Code, not including preceding @I and trailing @
    var INDI: Int?
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
    ///Death
    var death = Death()
    ///Sex
    var sex: Sex?
    ///Parent A (Usually Mother)
    var parentA: Person?
    ///Parent B (Usually Father)
    var parentB: Person?
    ///Tree that this person exists in
    var tree: Tree
    ///List of children
    var children: [Person] {
        get {
            var to_return = [Person]()
            for p in self.tree.people {
                if p.parentA?.INDI! == self.INDI! || p.parentB?.INDI! == self.INDI! {
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
                if p.INDI! == self.INDI! {
                    continue
                }
                if p.parentA?.INDI! == self.parentA?.INDI || p.parentA?.INDI! == self.parentB?.INDI {
                    to_return.append(p)
                } else if p.parentB?.INDI! == self.parentA?.INDI || p.parentB?.INDI! == self.parentB?.INDI {
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
                if p.INDI! == self.INDI! {
                    continue
                }
                if (p.parentA?.INDI! == self.parentA?.INDI || p.parentA?.INDI! == self.parentB?.INDI) && (p.parentB?.INDI! == self.parentA?.INDI || p.parentB?.INDI! == self.parentB?.INDI) {
                    to_return.append(p)
                }
            }
            return to_return
        }
    }

    
    init(gedcomEntity ge: [String], tree t: Tree) {
        self.tree = t
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

            dict["nameNow"] = self.nameNow.dictionaryWithValuesForKeys(["givenName","familyName","middleName","namePrefix","nameSuffix","nickname"])
            dict["nameAtBirth"] = self.nameAtBirth.dictionaryWithValuesForKeys(["givenName","familyName","middleName","namePrefix","nameSuffix","nickname"])
            dict["INDI"] = self.INDI!
            dict["birth"] = self.birth.dictionary
            dict["death"] = self.death.dictionary
            dict["sex"] = self.sex!.rawValue
            
            return dict
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
            let p = Person(gedcomEntity: entity, tree: tree)
            tree.people.append(p)
        }
    }
    for entity in firstLevelObjects {
        if entity[0].rangeOfString("FAM") != nil {
            
            let ge = entity
            var husband: Person?
            var wife: Person?
            var children = [Person]()
            
            for row in ge {
                if row.rangeOfString("HUSB") != nil {
                    let husbandID = Int(row.stringByReplacingOccurrencesOfString("1 HUSB @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                    husband = tree.getPerson(id: husbandID)
                } else if row.rangeOfString("WIFE") != nil {
                    let wifeID = Int(row.stringByReplacingOccurrencesOfString("1 WIFE @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                    wife = tree.getPerson(id: wifeID)
                } else if row.rangeOfString("CHIL") != nil {
                    let childID = Int(row.stringByReplacingOccurrencesOfString("1 CHIL @I", withString: "").stringByReplacingOccurrencesOfString("@", withString: ""))!
                    guard let child = tree.getPerson(id: childID) else {
                        continue
                    }
                    children.append(child)
                }
//                Type note used right now
//                } else if row.rangeOfString("MARR") != nil {
//                    self.type = FamilyType.Married
//                }
            }
            
            for child in children {
                if let wife = wife {
                    child.parentA = wife
                }
                if let husband = husband {
                    child.parentB = husband
                }
            }
        }
    }
    return tree
}