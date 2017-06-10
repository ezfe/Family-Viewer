//
//  Person.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 9/5/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation

func ==(l: Person, r: Person) -> Bool {
    return l.INDI == r.INDI
}
func <(l: Person, r: Person) -> Bool {
    return l.INDI < r.INDI
}

class Person: CustomStringConvertible, Comparable {
    ///Name String
    var description: String {
        get {
            let ret = self.getNameNow().isSet() ? "\(self.getNameNow().description) (#\(self.INDI))" : "Person \(self.INDI)"
            return ret
        }
    }
    ///Name components
    var nameNow = NameComponents()
    ///Maiden name
    var nameAtBirth = NameComponents()
    
    ///Notes about the person, allows for fields that don't already exist to be easily noted
    var notes = ""
    
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
        if nameNow.nameSuffix == nil {
            nameNow.nameSuffix = nameAtBirth.nameSuffix
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
    
    var mostProbableSpouse: Person? {
        var possibilities = self.partners
        possibilities.sort { (person1, person2) -> Bool in
            var p1Children = person1.children.filter { (child) -> Bool in
                return (child.parentA == self || child.parentB == self)
            }
            p1Children.sort { (child1, child2) -> Bool in
                return child1.birth.date > child2.birth.date
            }
            var p2Children = person2.children.filter { (child) -> Bool in
                return (child.parentA == self || child.parentB == self)
            }
            p2Children.sort { (child1, child2) -> Bool in
                return child1.birth.date > child2.birth.date
            }
            guard let child1 = p1Children.first, let child2 = p2Children.first else {
                return false
            }
            return child1.birth.date > child2.birth.date
        }
        return possibilities.first
    }
    
    var death = Death()
    var sex: Sex?
    
    ///Parent A (Usually Mother)
    weak var parentA: Person?
    ///Parent B (Usually Father)
    weak var parentB: Person?
    
    var tree: Tree
    
    var parents: [Person] {
        get {
            var retVal = Array<Person>()
            if let pA = self.parentA {
                retVal.append(pA)
            }
            if let pB = self.parentB {
                retVal.append(pB)
            }
            return retVal
        }
    }
    
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
    
    ///List the people this person has had children with
    var partners: [Person] {
        get {
            var to_return = [Person]()
            
            peopleLoop: for p in self.children {
                guard let parentA = p.parentA, let parentB = p.parentB else {
                    continue
                }
                if parentA == self {
                    for parent in to_return where parent == parentB {
                        continue peopleLoop
                    }
                    to_return.append(parentB)
                } else if parentB == self {
                    for parent in to_return where parent == parentA {
                        continue peopleLoop
                    }
                    to_return.append(parentA)
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
    
    func relationTo(person p: Person) -> String? {
        enum Visitor {
            case Me, Them
        }
        
        class AncestorPerson: CustomStringConvertible {
            let person: Person
            var myDistance: Int?
            var theirDistance: Int?
            var visitState: Int //0, 1, 2 (2 being both)
            
            init(person p: Person) {
                self.person = p
                self.visitState = 0
            }
            
            func visit() {
                self.visitState += 1
            }
            
            var description: String {
                get {
                    let mds = self.myDistance ?? -1
                    let tds = self.theirDistance ?? -1
                    return "\(person.description)::\(mds)/\(tds)::\(visitState)"
                }
            }
        }
        
        var ancestorsSet = Array<AncestorPerson>()
        
        func populateAncestors(from popPerson: Person, distance: Int, visitor: Visitor) {
            if !personInSet(popPerson) {
                let ap = AncestorPerson(person: popPerson)
                ap.visit()
                if visitor == .Me {
                    ap.myDistance = distance
                } else if visitor == .Them {
                    ap.theirDistance = distance
                }
                ancestorsSet.append(ap)
            } else {
                for a in ancestorsSet where a.person == popPerson {
                    a.visit()
                    switch visitor {
                    case .Me:
                        a.myDistance = distance
                    case .Them:
                        a.theirDistance = distance
                    }
                    break
                }
            }
            for parent in popPerson.parents {
                populateAncestors(from: parent, distance: distance + 1, visitor: visitor)
            }
        }
        
        func personInSet(person: Person) -> Bool {
            for a in ancestorsSet where a.person == person {
                return true
            }
            return false
        }
        
        populateAncestors(from: self, distance: 0, visitor: .Me)
        populateAncestors(from: p, distance: 0, visitor: .Them)
        
        for (i, a) in ancestorsSet.enumerated().reversed() {
            if (a.visitState != 2) {
                ancestorsSet.remove(at: i)
            }
        }
        
        ancestorsSet.sort { (a1, a2) -> Bool in
            if let a1d1 = a1.theirDistance, let a1d2 = a1.myDistance, let a2d1 = a2.theirDistance, let a2d2 = a2.myDistance {
                return (a1d1 + a1d2 < a2d1 + a2d2)
            } else {
                return false
            }
        }
        
        guard let lowestCommonAncestor = ancestorsSet.first else {
            return nil
        }
        
        guard let theirDistance = lowestCommonAncestor.theirDistance, let myDistance = lowestCommonAncestor.myDistance else {
            return nil
        }
        
        guard let theirSex = p.sex else {
            print("\(p.description)'s sex is not set")
            return nil
        }
        
        
        print(lowestCommonAncestor)
        
        if theirDistance == 0 || myDistance == 0 {
            var referralWord: String
            if theirDistance == 0 {
                switch theirSex {
                case .Male:
                    referralWord = "father"
                case .Female:
                    referralWord = "mother"
                }
                
                if myDistance == 1 {
                    return referralWord
                } else if myDistance == 2 {
                    return "grand\(referralWord)"
                } else if myDistance >= 3 {
                    var workingString = ""
                    for _ in 3...myDistance {
                        workingString += "great-"
                    }
                    return workingString + "grand-\(referralWord)"
                }
            } else if myDistance == 0 {
                switch theirSex {
                case .Male:
                    referralWord = "son"
                case .Female:
                    referralWord = "daughter"
                }
                
                if myDistance == 1 {
                    return referralWord
                } else if myDistance == 2 {
                    return "grand\(referralWord)"
                } else if myDistance >= 3 {
                    var workingString = ""
                    for _ in 3...myDistance {
                        workingString += "great-"
                    }
                    return workingString + "grand-\(referralWord)"
                }
            }
            return nil
        }
        
        /*
         * Some of the code below is based off code found on the following webpage
         * http://www.searchforancestors.com/utility/cousincalculator.html
         */
        
        if (myDistance == theirDistance) {
            if (myDistance == 1) {
                var relation: String
                switch theirSex {
                case .Male:
                    relation = "brother"
                case .Female:
                    relation = "sister"
                }
                if p.parentB != self.parentB || p.parentA != self.parentA {
                    relation = "half-" + relation
                }
                return relation
            } else {
                return numericalSuffix(myDistance - 1) + " cousin"
            }
        } else if (myDistance == 1 && theirDistance > 1) {
            var grands = "";
            if (theirDistance == 3) {
                grands = "grand-"
            } else if (theirDistance == 4) {
                grands = "great grand-"
            } else if (theirDistance >= 5) {
                grands = numericalSuffix(theirDistance - 1) + " great grand-"
            }
            switch theirSex {
            case .Male:
                return grands + "nephew"
            case .Female:
                return grands + "niece"
            }
        } else if (myDistance > 1 && theirDistance == 1) {
            var grands = "";
            if (myDistance == 3) {
                grands = "grand-"
            } else if (myDistance == 4) {
                grands = "great grand-"
            } else if (myDistance >= 5) {
                grands = numericalSuffix(myDistance - 1) + " great grand-"
            }
            switch theirSex {
            case .Male:
                return grands + "uncle"
            case .Female:
                return grands + "aunt"
            }
        } else {
            var lesser = 1;
            var removed = 0;
            if myDistance > theirDistance {
                lesser = theirDistance - 1;
                removed = myDistance - theirDistance
            } else {
                lesser = myDistance - 1;
                removed = theirDistance - myDistance
            }
            if removed > 0 {
                var theirrelation = numericalSuffix(lesser) + " cousins \(removed)";
                if (removed == 1) {
                    theirrelation += " time removed";
                } else {
                    theirrelation += " times removed"
                }
                return theirrelation
            } else {
                return numericalSuffix(lesser) + " cousins"
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
        for (i, row) in ge.enumerated() {
            if row.range(of: "INDI") != nil {
                self.INDI = Int(row.replacingOccurrences(of: "0 @I", with: "").replacingOccurrences(of: "@ INDI", with: ""))!
            } else if row.range(of: "NAME") != nil {
                for (x,row) in ge.enumerated() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.range(of: "GIVN") != nil {
                        let givenName = row.replacingOccurrences(of: "2 GIVN ", with: "")
                        self.nameAtBirth.givenName = givenName
                    } else if row.range(of: "_MARNM") != nil {
                        self.nameNow.familyName = row.replacingOccurrences(of: "2 _MARNM", with: "")
                    } else if row.range(of: "SURN") != nil {
                        self.nameAtBirth.familyName = row.replacingOccurrences(of: "2 SURN ", with: "")
                    }
                }
            } else if row.range(of: "BIRT") != nil {
                for (x,row) in ge.enumerated() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.range(of: "DATE") != nil {
                        let dateString = row.replacingOccurrences(of: "2 DATE ", with: "")
                        self.birth.date = convertFEDate(date: dateString)
                    } else if row.range(of: "PLAC") != nil {
//                        let placeString = row.replacingOccurrences(of: "2 PLAC ", with: "")
//                        Don't parse location for now, just have that entered later in UI
                    }
                }
            } else if row.range(of: "DEAT Y") != nil {
                self.isAlive = false
                for (x,row) in ge.enumerated() where x > i {
                    if row[0] == "1" {
                        break
                    }
                    if row.range(of: "DATE") != nil {
                        let dateString = row.replacingOccurrences(of: "2 DATE ", with: "")
                        self.death.dateOfDeath = convertFEDate(date: dateString)
                    } else if row.range(of: "PLAC") != nil {
//                        let placeString = row.stringByReplacingOccurrencesOfString("2 PLAC ", withString: "")
//                        Don't parse location for now, just have that entered later in UI
                    }
                }
            } else if row.range(of: "SEX") != nil {
                switch row.replacingOccurrences(of: "1 SEX ", with: "") {
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
    
    //MARK:- Print Tree
    
    func describe() {
        print("*------------- PERSON #\(self.INDI) DETAIL -------------*")
        
        print("         Name Now: ", terminator: "")
        if self.nameNow.isSet() {
            print(self.nameNow.description)
        } else if self.nameAtBirth.isSet() {
            print(self.nameAtBirth.description)
        } else {
            print("Name unknown")
        }
        
        print("    Date of Birth: ", terminator: "")
        if self.birth.date.isSet() {
            print(self.birth.date.description)
        } else {
            print("Unknown")
        }
        
        print("Location of Birth: ", terminator: "")
        print(self.birth.location)
        if !self.isAlive {
            print("")
            print("    Date of Death: ", terminator: "")
            if self.death.dateOfDeath.isSet() {
                print(self.death.dateOfDeath.description)
            } else {
                print("Unknown")
            }
            
            print("Location of Death: ", terminator: "")
            print(self.death.locationOfDeath)
        }
        print("")
        print("              Sex: \(self.sex?.rawValue ?? "Unknown")")
        print("")
        print("        Partners*: ", terminator: "")
        
        let partners = self.partners
        let currentPartner = self.mostProbableSpouse
        
        for (i, partner) in partners.enumerated() {
            if i == 0 {
                if partner == currentPartner && partners.count > 1 {
                    print(partner.description + " [Current?]")
                } else {
                    print(partner.description + "")
                }
            } else {
                if partner == currentPartner && partners.count > 1 {
                    print("                   " + partner.description + " [Current?]")
                } else {
                    print("                   " + partner.description)
                }
            }
        }
        
        if partners.count == 0 {
            print("None known")
        }
        
        print("")
        print("         Children: ", terminator: "")
        
        let children = self.children
        
        for (i, child) in children.enumerated() {
            if i == 0 {
                print(child.description + "")
            } else {
                print("                   " + child.description)
            }
        }
        
        if children.count == 0 {
            print("None")
        }
        
        print("")
        
        if let mother = self.parentA {
            print("           Mother: \(mother.description)")
        }
        if let father = self.parentB {
            print("           Father: \(father.description)")
        }
    }
    
    //MARK:- Dictionary Tools
    
    ///Dictionary representation of self
    var dictionary: NSMutableDictionary {
        get {
            let dict = NSMutableDictionary()
            
            dict["nameNow"] = self.nameNow.dictionary
            dict["nameAtBirth"] = self.nameAtBirth.dictionary
            dict["INDI"] = self.INDI
            dict["birth"] = self.birth.dictionary
            dict["death"] = self.death.dictionary
            dict["sex"] = self.sex!.rawValue
            dict["notes"] = self.notes
            
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
