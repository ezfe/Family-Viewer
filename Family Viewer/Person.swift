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
            let ret = self.getNameNow().isSet() ? self.getNameNow().description : "Person"
            let Str = "test"
            Str.characters.count
            return ret
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
        
        enum VisitState {
            case Me
            case Them
            case Both
            case None
        }
        
        class AncestorPerson: CustomStringConvertible {
            let person: Person
            var myDistance: Int?
            var theirDistance: Int?
            var visitState: VisitState
            
            init(person p: Person, visitState v: VisitState) {
                self.person = p
                self.visitState = v
            }
            
            func visitBy(visitor: Visitor) {
                switch visitState {
                case .Both:
                    break
                case .Me:
                    if visitor == .Them {
                        visitState = .Both
                    }
                case .Them:
                    if visitor == .Me {
                        visitState = .Both
                    }
                case .None:
                    if visitor == .Me {
                        visitState = .Me
                    } else if visitor == .Them {
                        visitState = .Them
                    }
                }
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
                var visitState: VisitState = .None
                if visitor == .Me {
                    visitState = .Me
                } else if visitor == .Them {
                    visitState = .Them
                }
                let ap = AncestorPerson(person: popPerson, visitState: visitState)
                if visitor == .Me {
                    ap.myDistance = distance
                } else if visitor == .Them {
                    ap.theirDistance = distance
                }
                ancestorsSet.append(ap)
            } else {
                for a in ancestorsSet {
                    if a.person == popPerson {
                        a.visitBy(visitor)
                        if visitor == .Me {
                            a.myDistance = distance
                        } else if visitor == .Them {
                            a.theirDistance = distance
                        }
                    }
                }
            }
            for parent in popPerson.parents {
                populateAncestors(from: parent, distance: distance + 1, visitor: visitor)
            }
        }
        
        func personInSet(person: Person) -> Bool {
            for a in ancestorsSet {
                if a.person == person {
                    return true
                }
            }
            return false
        }
        
        populateAncestors(from: self, distance: 0, visitor: .Me)
        populateAncestors(from: p, distance: 0, visitor: .Them)
        
        for (i, a) in ancestorsSet.enumerate().reverse() {
            if (a.visitState != .Both) {
                ancestorsSet.removeAtIndex(i)
            }
        }
        
        ancestorsSet.sortInPlace { (a1, a2) -> Bool in
            if let a1d1 = a1.theirDistance, a1d2 = a1.myDistance, a2d1 = a2.theirDistance, a2d2 = a2.myDistance {
                return (a1d1 + a1d2 < a2d1 + a2d2)
            } else {
                return false
            }
        }
        
        let relationships = [
            ["sibling","niece or nephew","grandniece or grandnephew","great grandniece or grandnephew","2nd great grandniece or grandnephew"],
            ["niece or nephew","1st cousin","1st cousin 1 time removed","1st cousin 2 times removed","1st cousin 3 times removed"],
            ["grandniece or grandnephew","1st cousin 1 time removed","2nd cousin","2nd cousin 1 time removed","2nd cousin 2 times removed"],
            ["great grandniece or grandnephew","1st cousin 2 times removed","2nd cousin 1 time removed","3rd cousin","3rd cousin 1 time removed"],
            ["2nd great grandniece or grandnephew","1st cousin 3 times removed","2nd cousin 2 times removed","3rd cousin 1 time removed","4th cousin"]
        ];
        
        guard let lowestCommonAncestor = ancestorsSet.first else {
            return nil
        }
        
        guard let theirDistance = lowestCommonAncestor.theirDistance, myDistance = lowestCommonAncestor.myDistance else {
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
        
        let t1 = myDistance - 1
        let t2 = theirDistance - 1
        
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
                return numericalSuffix(t1) + " cousin"
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
                grands = numericalSuffix(t1 - 2) + " great grand-"
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
            if (t1 > t2) {
                lesser = t2;
                removed = t1 - t2
            } else {
                lesser = t1;
                removed = t2 - t1
            }
            if (removed > 0) {
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
            dict["INDI"] = self.INDI
            dict["birth"] = self.birth.dictionary
            dict["death"] = self.death.dictionary
            dict["sex"] = self.sex!.rawValue
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
