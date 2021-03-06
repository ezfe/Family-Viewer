//
//  Tree.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 9/5/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation
import AppKit

class Tree: CustomStringConvertible, Codable {
    ///Wether this tree should be saved, expected to have values, etc.
    var realTree = false;
    
    var people = [Person]() {
        didSet {
            realTree = true;
            NotificationCenter.default.post(name: .FVTreeDidUpdate, object: self)
        }
    }

    enum SortingTypes: String, Codable {
        case A_FIRST
        case Z_FIRST
        case ID_SORT
    }

    var nextSort: SortingTypes = .A_FIRST

    func sortPeople(sortType: SortingTypes = .A_FIRST) {
        self.people.sort { (p1, p2) -> Bool in
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

    func getPerson(id: Int) -> Person? {
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
        for (i,p) in self.people.enumerated() {
            if p == person {
                return i
            }
        }
        return nil
    }

    ///Get a person by their name, either name works: Kezia Lind, Kezia Sørbøe
    func getPerson(givenName firstName: String, familyName lastName: String) -> Person? {
        for p in self.people {
            if let givenNameNow = p.nameNow.givenName, let familyNameNow = p.nameNow.familyName, givenNameNow.lowercased() == firstName.lowercased() && familyNameNow.lowercased() == lastName.lowercased() {
                return p
            }
            if let givenNameNow = p.nameAtBirth.givenName, let familyNameNow = p.nameAtBirth.familyName, givenNameNow.lowercased() == firstName.lowercased() && familyNameNow.lowercased() == lastName.lowercased() {
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
            return self.people.map { $0.description }
        }
    }

    ///NSMutableArray representation
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            let arr = NSMutableArray()
            for person in people {
                print("Imported \(person.description)")
//                arr.add(person.dictionary)
            }
            dict["people"] = arr
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                //If there's no app delegate, than more problems are present than a missing version tag
                //Just save it and hope the rest of the app works
                dict["version"] = appDelegate.formatVersion
            }
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
        INDIGen += 1
        return INDIGen
    }

    func describe() {
        for person in self.people.sorted(by: { (p1, p2) -> Bool in
            p1.birth.date > p2.birth.date
        }) {
            person.describe()
        }
    }
    
    ///Deletes duplicate INDI codes and assigns missing ones.
    func cleanupINDICodes() {
        for (i,p) in people.enumerated() {
            for (x,p2) in people.enumerated() where x != i {
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
        
        for (i, p2) in people.enumerated() {
            if p == p2 {
                people.remove(at: i)
                if !(self.people.count > 0) {
                    self.people.append(Person(tree: self))
                }
                self.selectedPerson = self.people[0]
                return true
            }
        }
        return false
    }

    func loadDictionary(dict: NSMutableDictionary, appFormat: Int?) {
        realTree = true;
        
        guard let currentFormat = appFormat else {
            displayAlert(title: "Warning", message: "Unable to read application version, which is required for safe opening")
            return
        }

        guard var dictFormat = dict["version"] as? Int else {
            //TODO: Make it not crash
            displayAlert(title: "Warning", message: "Dictionary doesn't have version tag, which is required for safe opening")
            return
        }
        
        /*
        if dictFormat < currentFormat {
            while dictFormat < currentFormat {
                print("Upgraded tree from format \(dictFormat) to format \(dictFormat + 1)")
                if dictFormat == 1 {
                    //There are no changes needed to convert 1 to 2
                    dictFormat += 1
                    continue
                } else if dictFormat == 2 {
                    //Changes in Death Dictionary
                    /*
                     people[x][death][date] ==> people[x][death][dateOfDeath]
                     people[x][death][location] ==> people[x][death][locationOfDeath]
                    */
                    
                    if let arr = dict["people"] as? NSArray {
                        guard let mutablePeopleArr = arr.mutableCopy() as? NSMutableArray else {
                            return
                        }
                        for (i, personDictionary) in arr.enumerated() {
                            guard let mutablePerson = (personDictionary as? AnyObject)?.mutableCopy() as? NSMutableDictionary else {
                                return
                            }
                            if let deathDict = personDictionary["death"] as? NSDictionary {
                                guard let mutableDeathDict = deathDict.mutableCopy() as? NSMutableDictionary else {
                                    return
                                }
                                guard let date = deathDict["date"], let location = deathDict["location"] else {
                                    return
                                }
                                mutableDeathDict.setObject(date, forKey: "dateOfDeath")
                                mutableDeathDict.setObject(location, forKey: "locationOfDeath")
                                mutablePerson.setObject(mutableDeathDict, forKey: "death")
                            }
                            //No need to else{} because no death dictionary will be created with the right format
                            
                            mutablePeopleArr.removeObject(at: i)
                            mutablePeopleArr.addObject(mutablePerson)
                        }
                        dict.setObject(mutablePeopleArr, forKey: "people")
                    }
                    //No need to else{}, because the dictionary won't open anyways, so the version doesn't matter
                    
                    dictFormat += 1
                    continue
                }
            }
        } else if dictFormat > currentFormat {
            displayAlert("Error", message: "Dictionary is (too) new, won't open")
            return
        }
         */

        if let treeName = dict["name"] as? String {
            self.treeName = treeName
        }

        guard let peopleArray = dict["people"] as? [[String: Any]] else {
            displayAlert(title: "Error", message: "Unable to find people array")
            return
        }
        for pDict in peopleArray {
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
                    print("Imported birth location for \(p.description)")
                    p.birth.location = location
                } else {
                    print("Couldn't import birth location for \(p.description). Here's the dictionary")
                    print(birthDict)
                }
            }

            if let deathDict = pDict["death"] as? NSDictionary {
                if let dateDict = deathDict["dateOfDeath"] as? NSDictionary {
                    if let day = dateDict["day"] as? Int {
                        p.death.dateOfDeath.day = day
                    }
                    if let monthString = dateDict["month"] as? String {
                        p.death.dateOfDeath.month = monthFromRaw(month: monthString)
                    }
                    if let year = dateDict["year"] as? Int {
                        p.death.dateOfDeath.year = year
                    }
                }
                if let dateDict = deathDict["dateOfBurial"] as? NSDictionary {
                    if let day = dateDict["day"] as? Int {
                        p.death.dateOfBurial.day = day
                    }
                    if let monthString = dateDict["month"] as? String {
                        p.death.dateOfBurial.month = monthFromRaw(month: monthString)
                    }
                    if let year = dateDict["year"] as? Int {
                        p.death.dateOfBurial.year = year
                    }
                }
                if let location = deathDict["locationOfDeath"] as? String {
                    print("Imported death location for \(p.description)")
                    p.death.locationOfDeath = location
                } else {
                    print("Couldn't import death location for \(p.description). Here's the dictionary")
                    print(deathDict)
                }
                if let location = deathDict["locationOfBurial"] as? String {
                    print("Imported burial location for \(p.description)")
                    p.death.locationOfBurial = location
                } else {
                    print("Couldn't import burial location for \(p.description). Here's the dictionary")
                    print(deathDict)
                }
                if let hasDied = deathDict["hasDied"] as? Bool {
                    print("Imported hasDied attribute for \(p.description)")
                    p.isAlive = !hasDied
                }
            }

            if let nameAtBirthDict = pDict["nameAtBirth"] as? NSDictionary {
                p.nameAtBirth.setupFromDict(dictionary: nameAtBirthDict)
                print("Imported name at birth for \(p.description)")
            }

            if let nameNowDict = pDict["nameNow"] as? NSDictionary {
                p.nameNow.setupFromDict(dictionary: nameNowDict)
                print("Imported name now for \(p.description)")
            }

            if let sexString = pDict["sex"] as? String {
                if sexString == "Male" {
                    p.sex = Sex.male
                } else if sexString == "Female" {
                    p.sex = Sex.female
                }
            }
            
            if let notes = pDict["notes"] as? String {
                p.notes = notes
            }

            self.people.append(p)
        }
        //Second loop to add parents
        for pDict in peopleArray {
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
