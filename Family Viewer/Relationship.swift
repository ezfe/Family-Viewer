//
//  Relationship.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 4/11/16.
//  Copyright © 2016 Ezekiel Elin. All rights reserved.
//

import Foundation

class Relationship {
    private var _people = [Person]()
    
    var people: [Person] {
        set(value) {
            if value.count > 2 {
                _people = [value[0],value[1]]
            } else {
                _people = value
            }
        }
        get {
            return _people
        }
    }
    
    init(personA: Person, personB: Person) {
        self.people.append(personA)
        self.people.append(personB)
    }
}

class Marriage: Relationship {
    var divorced: Bool
    
    ///Date of marriage
    var marriageDate = Date()
    
    ///Date of divorce
    var divorceDate = Date()
    
    init(personA: Person, personB: Person, divorced: Bool) {
        self.divorced = divorced
        super.init(personA: personA, personB: personB)
    }
}