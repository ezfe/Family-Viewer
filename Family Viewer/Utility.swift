//
//  Utility.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation
import Cocoa

//MARK: App-wide functions and extensions

func == (left: Person?, right: Person?) -> Bool {
    guard let left = left, right = right else {
        return false
    }
    return left.INDI! == right.INDI!
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}

extension NSButton {
    var isChecked: Bool {
        get {
            return (self.stringValue == "1")
        }
        set {
            if newValue {
                self.stringValue = "1"
            } else {
                self.stringValue = "0"
            }
        }
    }
}

//MARK: - Tree

///Represents the entire tree
class Tree: CustomStringConvertible {
    ///List of Person objects in the tree
    var people = [Person]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self)
        }
    }
    
    ///Name of the tree
    var treeName = "Family Tree"
    
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
            if let givenNameNow = p.nameNow.givenName, familyNameNow = p.nameNow.familyName where givenNameNow.lowercaseString == firstName.lowercaseString && familyNameNow.lowercaseString == lastName.lowercaseString {
                return p
            }
            if let givenNameNow = p.nameAtBirth.givenName, familyNameNow = p.nameAtBirth.familyName where givenNameNow.lowercaseString == firstName.lowercaseString && familyNameNow.lowercaseString == lastName.lowercaseString {
                    return p
            }
        }
        return nil
    }
    
    ///Description of the treex
    var description: String {
        get {
            return "Tree with \(people.count) people"
        }
    }
    
    ///NSMutableArray representation
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            let arr = NSMutableArray()
            for person in people {
                print("Added \(person.INDI!) to the array")
                arr.addObject(person.dictionary)
            }
            dict["people"] = arr
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            dict["version"] = appDelegate.formatVersion
            dict["name"] = self.treeName
            return dict
        }
    }
    
    ///Returns a safe INDI code to use for a new object in this tree
    func getUniqueINDI() -> Int {
        var INDIGen = 1
        for p in self.people {
            if p.INDI! >= INDIGen {
                INDIGen = p.INDI!
            }
        }
        return ++INDIGen
    }
    
    ///Deletes duplicate INDI codes and assigns missing ones.
    func cleanupINDICodes() {
        for (i,p) in people.enumerate() {
            for (x,p2) in people.enumerate() where x != i {
                if p == p2 {
                    p2.INDI = self.getUniqueINDI()
                    print("Assigned new INDI (\(p2.INDI!)) to \(p2.description)")
                }
            }
        }
    }
    
    init() {} //dunno if i need this
    
    init(dictionary dict: NSDictionary) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let currentFormat = appDelegate.formatVersion
        guard let dictFormat = dict["version"] as? Int else {
            //TODO: Make it not crash
            assert(false,"Dictionary doesn't have version tag")
            return
        }
        
        if dictFormat < currentFormat {
            //TODO: Make it not crash
            assert(false,"Dictionary is old, cannot open")
        } else if dictFormat > currentFormat {
            //TODO: Make it not crash
            assert(false,"Dictionary is (too) new, won't open")
        }
        
        if let treeName = dict["name"] as? String {
            self.treeName = treeName
        }
        
        let arr = dict["people"] as! NSArray
        for pDict in arr {
            let p = Person(tree: self)
            if let INDICode = pDict["INDI"] as? Int {
                p.INDI = INDICode
            } else {
                //TODO: Make it not crash, just cancel import
                assert(false,"Missing INDI code, not importing")
            }

            if let birthDict = pDict["birth"] as? NSDictionary {
                if let dateDict = birthDict["date"] as? NSDictionary {
                    if let day = dateDict["day"] as? Int {
                        p.birth.date.day = day
                    }
                    if let monthString = dateDict["month"] as? String {
                        p.birth.date.month = monthFromRaw(month: monthString)
                    }
                    if let year = dateDict["year"] as? Int {
                        p.birth.date.year = year
                    }
                }
                if let location = birthDict["location"] as? String {
                    print("Imported birth location")
                    p.birth.location = location
                } else {
                    print("Couldn't import birth location. Here's the dictionary")
                    print(birthDict)
                }
            }
            
            if let deathDict = pDict["death"] as? NSDictionary {
                if let dateDict = deathDict["date"] as? NSDictionary {
                    if let day = dateDict["day"] as? Int {
                        p.death.date.day = day
                    }
                    if let monthString = dateDict["month"] as? String {
                        p.death.date.month = monthFromRaw(month: monthString)
                    }
                    if let year = dateDict["year"] as? Int {
                        p.death.date.year = year
                    }
                }
                if let location = deathDict["location"] as? String {
                    print("Imported death location")
                    p.death.location = location
                } else {
                    print("Couldn't import death location. Here's the dictionary")
                    print(deathDict)
                }
                if let hasDied = deathDict["hasDied"] as? Bool {
                    print("Imported hasDied attribute")
                    p.isAlive = !hasDied
                }
            }
            
            if let nameAtBirthDict = pDict["nameAtBirth"] as? NSDictionary {
                p.nameAtBirth.setupFromDict(dictionary: nameAtBirthDict)
                print("Imported name at birth")
            }
            
            if let nameNowDict = pDict["nameNow"] as? NSDictionary {
                p.nameNow.setupFromDict(dictionary: nameNowDict)
                print("Imported name now")
            }
            
            if let sexString = pDict["sex"] as? String {
                if sexString == "Male" {
                    p.sex = Sex.Male
                } else if sexString == "Female" {
                    p.sex = Sex.Female
                }
            }
            
            self.people.append(p)
        }
        //Second loop to add parents
        for pDict in arr {
            if let INDICode = pDict["INDI"] as? Int, let p = self.getPerson(id: INDICode) {
                if let pAINDI = pDict["parentA"] as? Int {
                    print("Imported Parent A (\(pAINDI) for \(p.INDI!))")
                    p.parentA = self.getPerson(id: pAINDI)
                } else {
                    print("No parent found for \(p.INDI!)")
                }
                if let pBINDI = pDict["parentB"] as? Int {
                    print("Imported Parent B (\(pBINDI) for \(p.INDI!))")
                    p.parentB = self.getPerson(id: pBINDI)
                } else {
                    print("No parent found for \(p.INDI!)")
                }
            }
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

//MARK: - Person
///Represents a person in the family
class Person: CustomStringConvertible {
    ///Name String
    var description: String {
        get {
            let name = self.getNameNow()
            if let givenName = name.givenName, familyName = name.familyName {
                return "\(givenName) \(familyName)"
            } else {
                if let givenName = name.givenName {
                    return givenName
                }
                return "Person \(self.INDI!)"
            }
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
                if p.parentA! == self.parentA! || p.parentA! == self.parentB! {
                    to_return.append(p)
                } else if p.parentB! == self.parentA! || p.parentB! == self.parentB! {
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
    
    init(tree t: Tree) {
        self.tree = t
        self.INDI = tree.getUniqueINDI()
        //TODO: Better solution than storing male by default
        self.sex = Sex.Male
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
            
            dict["nameNow"] = self.nameNow.dictionary
            dict["nameAtBirth"] = self.nameAtBirth.dictionary
            dict["INDI"] = self.INDI!
            dict["birth"] = self.birth.dictionary
            dict["death"] = self.death.dictionary
            dict["sex"] = self.sex!.rawValue
            if let pA = self.parentA {
                dict["parentA"] = pA.INDI!
            }
            if let pB = self.parentB {
                dict["parentB"] = pB.INDI!
            }
            
            return dict
        }
    }
}

extension NameComponents {
    var dictionary: NSDictionary {
        get {
            let dict = NSMutableDictionary()
            
            dict["namePrefix"] = (self.namePrefix == nil ? "##nil##" : self.namePrefix!)
            dict["givenName"] = (self.givenName == nil ? "##nil##" : self.givenName!)
            dict["middleName"] = (self.middleName == nil ? "##nil##" : self.middleName!)
            dict["familyName"] = (self.familyName == nil ? "##nil##" : self.familyName!)
            dict["nameSuffix"] = (self.nameSuffix == nil ? "##nil##" : self.nameSuffix!)
            dict["nickname"] = (self.nickname == nil ? "##nil##" : self.nickname!)
            
            return dict
        }
    }
    
    func setupFromDict(dictionary dict: NSDictionary) {
        if let namePrefix = dict["namePrefix"] as? String where namePrefix != "##nil##" {
            self.namePrefix = namePrefix
        } else {
            self.namePrefix = nil
        }
        if let givenName = dict["givenName"] as? String where givenName != "##nil##" {
            self.givenName = givenName
        } else {
            self.givenName = nil
        }
        if let middleName = dict["middleName"] as? String where middleName != "##nil##" {
            self.middleName = middleName
        } else {
            self.middleName = nil
        }
        if let familyName = dict["familyName"] as? String where familyName != "##nil##" {
            self.familyName = familyName
        } else {
            self.familyName = nil
        }
        if let nameSuffix = dict["nameSuffix"] as? String where nameSuffix != "##nil##" {
            self.nameSuffix = nameSuffix
        } else {
            self.nameSuffix = nil
        }
        if let nickname = dict["nickname"] as? String where nickname != "##nil##" {
            self.nickname = nickname
        } else {
            self.nickname = nil
        }
    }
}

//MARK: - Dates

enum Month: String {
    case January = "January"
    case February = "February"
    case March = "March"
    case April = "April"
    case May = "May"
    case June = "June"
    case July = "July"
    case August = "August"
    case September = "September"
    case October = "October"
    case November = "November"
    case December = "December"
}

struct Date: CustomStringConvertible {
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
                dict["month"] = month.rawValue
            }
            if let year = year {
                dict["year"] = year
            }
            return dict
        }
    }
    
    func isSet() -> Bool {
        if self.day == nil && self.month == nil && self.year == nil {
            return false
        }
        return true
    }
    
    var description: String {
        get {
            if let day = self.day, month = self.month, year = self.year {
                return "\(month.rawValue) \(day), \(year)"
            }
            if let month = self.month, year = self.year {
                return "\(month.rawValue) \(year)"
            }
            if let year = self.year {
                return "\(year)"
            }
            return "\(month) \(day), \(year)"
        }
    }
}

func monthFromFEString(month mo: String) -> Month? {
    switch mo {
    case "JAN":
        return Month.January
    case "FEB":
        return Month.February
    case "MAR":
        return Month.March
    case "APR":
        return Month.April
    case "MAY":
        return Month.May
    case "JUN":
        return Month.June
    case "JUL":
        return Month.July
    case "AUG":
        return Month.August
    case "SEP":
        return Month.September
    case "OCT":
        return Month.October
    case "NOV":
        return Month.November
    case "DEC":
        return Month.December
    default:
        return nil
    }
}
func monthFromRaw(month mo: String) -> Month? {
    switch mo {
    case "January":
        return Month.January
    case "February":
        return Month.February
    case "March":
        return Month.March
    case "April":
        return Month.April
    case "May":
        return Month.May
    case "June":
        return Month.June
    case "July":
        return Month.July
    case "August":
        return Month.August
    case "September":
        return Month.September
    case "October":
        return Month.October
    case "November":
        return Month.November
    case "December":
        return Month.December
    default:
        return nil
    }
}
///Converts DD MMM YYYY to Date() object
func convertFEDate(date d: String) -> Date {
    if d.characters.count == 10 {
        let day = Int(d[0..<1])
        let monthString = d[2...4]
        let year = Int(d[6...9])
        return Date(day: day, month: monthFromFEString(month: monthString), year: year)
    } else if d.characters.count == 11 {
        let day = Int(d[0..<2])
        let monthString = d[3...5]
        let year = Int(d[7...10])
        return Date(day: day, month: monthFromFEString(month: monthString), year: year)
    }
    return Date(day: nil, month: nil, year: nil)
}

//MARK: Birth and Death

struct Birth {
    var date: Date = Date(day: nil, month: nil, year: nil)
    var location: String = ""
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            dict["date"] = date.dictionary
            dict["location"] = location
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
    var location: String = ""
    
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            dict["date"] = date.dictionary
            dict["location"] = location
            dict["hasDied"] = hasDied
            return dict
        }
    }
}

//MARK: - GEDCOM Compatibility

func GEDCOMToFamilyObject(gedcomString inputData: String) -> Tree {
    let tree = Tree()
    var rows = (inputData.componentsSeparatedByString("\n"))
    rows.removeLast()
    if (rows[0][0] != "0") {
        //TODO: Make it not crash, just cancel import
        assert(false, "First row isn't Level:0")
    }
    for (i,row) in rows.enumerate() {
        if (row.characters.count == 0) {
            //TODO: Make it not crash, just cancel import
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

//TODO: Make this better
func displayAlert(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.runModal()
}