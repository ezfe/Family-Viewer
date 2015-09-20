//
//  Tree.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 9/5/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation
import AppKit

class Tree: CustomStringConvertible {
    var people = [Person]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: self)
        }
    }

    enum SortingTypes {
        case A_FIRST
        case Z_FIRST
        case ID_SORT
    }

    var nextSort: SortingTypes = .A_FIRST

    func sortPeople(sortType: SortingTypes = .A_FIRST) {
        self.people.sortInPlace { (p1, p2) -> Bool in
            if sortType == .A_FIRST {
                return p1.description > p2.description
            } else if sortType == .Z_FIRST {
                return p1.description < p2.description
            } else /*if sortType == .ID_SORT*/ {
                return p1.INDI < p2.INDI
            }
        }

        switch sortType {
        case .A_FIRST:
            self.nextSort = .Z_FIRST
        case .Z_FIRST:
            self.nextSort = .ID_SORT
        case .ID_SORT:
            self.nextSort = .A_FIRST
        }
    }

    var selectedPerson: Person?

    private let DEFAULT_TREE_NAME = "Family Tree"
    var treeName: String

    func getPerson(id id: Int) -> Person? {
        for p in self.people {
            if p.INDI == id {
                return p
            }
        }
        return nil
    }

    /**
    Get the index of a person in the list

    Returned value is not a constant ID for the person

    (Use person.INDI for this)
    */
    func getIndexOfPerson(person: Person) -> Int? {
        for (i,p) in self.people.enumerate() {
            if p == person {
                return i
            }
        }
        return nil
    }

    ///Get a person by their name, either name works: Kezia Lind, Kezia Sørbøe
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

    var description: String {
        get {
            return "Tree with \(people.count) people"
        }
    }

    ///List of Person objects in [Name, Name, Name] format
    var peopleNameList: [String] {
        get {
            var to_return = [String]()
            for p in people {
                to_return.append(p.description)
            }
            return to_return
        }
    }

    ///NSMutableArray representation
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            let arr = NSMutableArray()
            for person in people {
                print("Added \(person.INDI) to the array")
                arr.addObject(person.dictionary)
            }
            dict["people"] = arr
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            dict["version"] = appDelegate.formatVersion
            dict["name"] = self.treeName
            //Store using INDI because we don't want to store it as a dictionary
            dict["selectedPerson"] = self.selectedPerson?.INDI
            return dict
        }
    }

    ///Returns a safe INDI code to use for a new object in this tree
    func getUniqueINDI() -> Int {
        var INDIGen = 1
        for p in self.people {
            if p.INDI >= INDIGen {
                INDIGen = p.INDI
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
                    print("Assigned new INDI (\(p2.INDI)) to \(p2.description)")
                }
            }
        }
    }

    init() {
        self.treeName = DEFAULT_TREE_NAME
    }

    func resetTree() {
        self.people.removeAll()
        self.treeName = DEFAULT_TREE_NAME
    }
    
    func removePerson(p: Person) -> Bool {
        print("Tree recevied request to delete \(p)")
        
        p.cleanupAssociationsForDeletion()
        
        for (i, p2) in people.enumerate() {
            if p == p2 {
                people.removeAtIndex(i)
                if !(self.people.count > 0) {
                    self.people.append(Person(tree: self))
                }
                self.selectedPerson = self.people[0]
                return true
            }
        }
        return false
    }

    func loadDictionary(dict: NSDictionary, appFormat: Int?) {
        guard let currentFormat = appFormat else {
            fatalError("No format passed")
        }

        guard let dictFormat = dict["version"] as? Int else {
            //TODO: Make it not crash
            assert(false, "Dictionary doesn't have version tag")
            return
        }

        if dictFormat < currentFormat {
            //TODO: Make it not crash
            assert(false, "Dictionary is old, cannot open")
        } else if dictFormat > currentFormat {
            //TODO: Make it not crash
            assert(false, "Dictionary is (too) new, won't open")
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
                assert(false, "Missing INDI code, not importing")
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
                if let parentA_INDI = pDict["parentA"] as? Int {
                    print("Imported Parent A (\(parentA_INDI) for \(p.INDI))")
                    p.parentA = self.getPerson(id: parentA_INDI)
                } else {
                    print("No parent found for \(p.INDI)")
                }
                if let parentB_INDI = pDict["parentB"] as? Int {
                    print("Imported Parent B (\(parentB_INDI) for \(p.INDI))")
                    p.parentB = self.getPerson(id: parentB_INDI)
                } else {
                    print("No parent found for \(p.INDI)")
                }
            }
        }

        //Set selected person
        if let selectedPersonINDI = dict["selectedPerson"] as? Int {
            self.selectedPerson = getPerson(id: selectedPersonINDI)
        }
    }
}
