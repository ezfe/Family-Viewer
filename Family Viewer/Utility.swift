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

enum Sex: String, Codable {
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

enum Month: String, Comparable, Codable {
    case january = "January"
    case february = "February"
    case march = "March"
    case april = "April"
    case may = "May"
    case june = "June"
    case july = "July"
    case august = "August"
    case september = "September"
    case october = "October"
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

struct Date: Codable, Comparable {
    var day: Int? = nil
    var month: Month? = nil
    var year: Int? = nil
    
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
        return Month.march
    case "APR":
        return Month.april
    case "MAY":
        return Month.may
    case "JUN":
        return Month.june
    case "JUL":
        return Month.july
    case "AUG":
        return Month.august
    case "SEP":
        return Month.september
    case "OCT":
        return Month.october
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
        return Month.march
    case "April":
        return Month.april
    case "May":
        return Month.may
    case "June":
        return Month.june
    case "July":
        return Month.july
    case "August":
        return Month.august
    case "September":
        return Month.september
    case "October":
        return Month.october
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
        case .march: return 3
        case .april: return 4
        case .may: return 5
        case .june: return 6
        case .july: return 7
        case .august: return 8
        case .september: return 9
        case .october: return 10
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

struct Birth: Codable {
    var date: Date = Date(day: nil, month: nil, year: nil)
    var location: String = ""
}

struct Death: Codable {
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
