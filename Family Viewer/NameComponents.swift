//
//  NameComponents.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 7/22/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Foundation

//Temporary Placeholder

class NameComponents: CustomStringConvertible {
    
    var namePrefix: String?
    var givenName: String?
    var middleName: String?
    var familyName: String?
    var nameSuffix: String?
    var nickname: String?
    
    var lastInitial: String? {
        get {
            return familyName![0]
        }
    }
    
    ///Returns wether description will work
    ///If this is false, then description may print NONAME
    func isSet() -> Bool {
        if let _ = self.familyName {
            if let _ = self.nickname {
                return true;
            } else if let _ = self.givenName {
                return true;
            }
        }
        return false;
    }
    
    var description: String {
        get {
            var first: String
            var last: String
            var suffix: String
            var prefix: String
            if let nick = self.nickname {
                first = nick
            } else if let name = self.givenName {
                first = name
            } else {
                first = "First"
            }
            if let familyName = familyName {
                last = familyName
            } else {
                last = "Last"
            }
            if let namePrefix = self.namePrefix {
                prefix = "\(namePrefix) "
            } else {
                prefix = ""
            }
            if let nameSuffix = self.nameSuffix {
                suffix = " \(nameSuffix)"
            } else {
                suffix = ""
            }
            
            return "\(prefix)\(first) \(last)\(suffix)"
        }
    }
}