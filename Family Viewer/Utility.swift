//
//  Utility.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation
import Cocoa
import MapKit

//MARK: App-wide functions and extensions

func == (left: Person?, right: Person?) -> Bool {
    guard let left = left, right = right else {
        return false
    }
    return left.INDI == right.INDI
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(startIndex.advancedBy(r.startIndex) ..< startIndex.advancedBy(r.endIndex)))
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

enum Sex: String {
    case Male = "Male"
    case Female = "Female"
}

enum FamilyType {
    case Married, Engaged, Relationship, Seperated, Divorced, Annulled
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

enum XcodeTag: Int {
    case MainBrowserTable  = 20
    case PersonDetailTable = 60
}

func getXcodeTag(tag: Int) -> XcodeTag {
    if let xctag = XcodeTag(rawValue: tag) {
        return xctag
    } else {
        assert(false, "Unable to initialize XcodeTag")
        return Optional()!
    }
}

enum TableActions {
    case EditName
    case EditBirth
    case EditDeath
    case SetParentA
    case SetParentB
    case ToggleSex
    case TreeView
}

/*
* http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
*/
func centerMapOnLocation(map: MKMapView, location: CLLocation, radius: CLLocationDistance) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        radius * 2.0, radius * 2.0)
    map.setRegion(coordinateRegion, animated: true)
}

func treeIsNilError() {
    print("The tree is nil, cancelling current operation")
}