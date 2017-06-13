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

func ==(left: Person?, right: Person?) -> Bool {
    guard let left = left, let right = right else {
        return false
    }
    return left.INDI == right.INDI
}

enum Sex: String {
    case male = "Male"
    case female = "Female"
}

enum FamilyType {
    case Married, Engaged, Relationship, Seperated, Divorced, Annulled
}

//MARK: - Dates

func <(m1: Month, m2: Month) -> Bool {
    return (m1.toIndex() < m2.toIndex())
}

enum Month: String, Comparable {
    case january = "January"
    case february = "February"
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

extension Date {
    public static func ==(date1: Date, date2: Date) -> Bool {
        return date1.day == date2.day && date1.month == date2.month && date1.year == date2.year
    }
    
    public static func <(date1: Date, date2: Date) -> Bool {
        if date1.year == date2.year {
            if date1.month == date2.month {
                return date1.day ?? 0 < date2.day ?? 0
            } else {
                return date1.month ?? .january < date2.month ?? .january
            }
        } else {
            return date1.year ?? 0 < date2.year ?? 0
        }
    }
}

struct Date: CustomStringConvertible, Comparable {
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
            if let day = self.day, let month = self.month, let year = self.year {
                return "\(month.rawValue) \(numericalSuffix(day)), \(year)"
            }
            if let month = self.month, let year = self.year {
                return "\(month.rawValue) \(year)"
            }
            if let day = self.day, let month = self.month {
                return "\(month.rawValue) \(numericalSuffix(day))"
            }
            if let year = self.year {
                return "\(year)"
            }
            return "Month ##th, ####"
        }
    }
}

func monthFromFEString(month mo: String) -> Month? {
    switch mo {
    case "JAN":
        return Month.january
    case "FEB":
        return Month.february
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
        return Month.january
    case "February":
        return Month.february
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
extension Month {
    func toIndex() -> Int {
        switch self {
        case .january: return 1
        case .february: return 2
        case .March: return 3
        case .April: return 4
        case .May: return 5
        case .June: return 6
        case .July: return 7
        case .August: return 8
        case .September: return 9
        case .October: return 10
        case .November: return 11
        case .December: return 12
        }
    }
}
///Converts DD MMM YYYY to Date() object
func convertFEDate(dateString: String) -> Date {
    let dayStart = dateString.startIndex
    let dayEnd: String.Index
    
    if dateString.count == 10 {
        dayEnd = dateString.index(after: dayStart)
    } else {
        dayEnd = dateString.index(dayStart, offsetBy: 2)
        
    }
    
    let day = Int(String(dateString[dayStart..<dayEnd]))
    
    let monthStart = dateString.index(after: dayEnd)
    let monthEnd = dateString.index(monthStart, offsetBy: 3)
    
    let monthString = dateString[monthStart..<monthEnd]
    
    let yearStart = dateString.index(after: monthEnd)
    let yearEnd = dateString.endIndex
    
    let year = Int(String(dateString[yearStart..<yearEnd]))
    
    return Date(day: day, month: monthFromFEString(month: String(monthString)), year: year)
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
    ///Has this person died
    var hasDied = false
    
    ///Date of death
    var dateOfDeath: Date = Date(day: nil, month: nil, year: nil)
    ///Place of death
    var locationOfDeath: String = ""
    
    ///Date of burial
    var dateOfBurial: Date = Date(day: nil, month: nil, year: nil)
    ///Place of burial
    var locationOfBurial: String = ""
    
    
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            dict["dateOfDeath"] = dateOfDeath.dictionary
            dict["locationOfDeath"] = locationOfDeath
            dict["dateOfBurial"] = dateOfBurial.dictionary
            dict["locationOfBurial"] = locationOfBurial
            dict["hasDied"] = hasDied
            return dict
        }
    }
}

//MARK: - GEDCOM Compatibility

func GEDCOMToFamilyObject(gedcomString inputData: String) -> Tree {
    let tree = Tree()
    var rows = inputData.components(separatedBy: "\n")
    rows.removeLast()
    if (rows[0].first != "0") {
        //TODO: Make it not crash, just cancel import
        assert(false, "First row isn't Level:0")
    }
    for (i,row) in rows.enumerated() {
        if (row.characters.count == 0) {
            //TODO: Make it not crash, just cancel import
            assert(false, "Empty row!")
        }
        rows[i] = row.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var firstLevelObjects = [[String]]()
    var workingEntity = [String]()
    
    for (i,row) in rows.enumerated() {
        let rowLevel = Int(row[0])!
        if i != 0 && rowLevel == 0 {
            firstLevelObjects.append(workingEntity)
            workingEntity = [String]()
        }
        workingEntity.append(row)
    }
    
    for entity in firstLevelObjects {
        if entity[0].range(of: "INDI") != nil {
            let p = Person(gedcomEntity: entity, tree: tree)
            tree.people.append(p)
        }
    }
    for entity in firstLevelObjects {
        if entity[0].range(of: "FAM") != nil {
            
            let ge = entity
            var husband: Person?
            var wife: Person?
            var children = [Person]()
            
            for row in ge {
                if row.range(of: "HUSB") != nil {
                    let husbandID = Int(row.replacingOccurrences(of: "1 HUSB @I", with: "").replacingOccurrences(of: "@", with: ""))!
                    husband = tree.getPerson(id: husbandID)
                } else if row.range(of: "WIFE") != nil {
                    let wifeID = Int(row.replacingOccurrences(of: "1 WIFE @I", with: "").replacingOccurrences(of: "@", with: ""))!
                    wife = tree.getPerson(id: wifeID)
                } else if row.range(of: "CHIL") != nil {
                    let childID = Int(row.replacingOccurrences(of: "1 CHIL @I", with: "").replacingOccurrences(of: "@", with: ""))!
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
    case PartnersTable = 60
    case ChildrenTable = 80
}

func getXcodeTag(tag: Int) -> XcodeTag {
    if let xctag = XcodeTag(rawValue: tag) {
        return xctag
    } else {
        assertionFailure("Unable to initialize XcodeTag")
        return XcodeTag.MainBrowserTable
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

func numericalSuffix(_ n: Int) -> String {
    var suffix: String
    let ones = n % 10;
    let tens = (n/10) % 10;
    
    if tens == 1 {
        suffix = "th";
    } else if ones == 1{
        suffix = "st";
    } else if ones == 2{
        suffix = "nd";
    } else if ones == 3{
        suffix = "rd";
    } else {
        suffix = "th";
    }
    
    return "\(n)\(suffix)";
    
}
