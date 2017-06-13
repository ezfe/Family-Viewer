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
            if let familyName = self.familyName {
                return String(familyName.first ?? "?")
            } else {
                return "?"
            }
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
        if let namePrefix = dict["namePrefix"] as? String, namePrefix != "##nil##" {
            self.namePrefix = namePrefix
        } else {
            self.namePrefix = nil
        }
        if let givenName = dict["givenName"] as? String, givenName != "##nil##" {
            self.givenName = givenName
        } else {
            self.givenName = nil
        }
        if let middleName = dict["middleName"] as? String, middleName != "##nil##" {
            self.middleName = middleName
        } else {
            self.middleName = nil
        }
        if let familyName = dict["familyName"] as? String, familyName != "##nil##" {
            self.familyName = familyName
        } else {
            self.familyName = nil
        }
        if let nameSuffix = dict["nameSuffix"] as? String, nameSuffix != "##nil##" {
            self.nameSuffix = nameSuffix
        } else {
            self.nameSuffix = nil
        }
        if let nickname = dict["nickname"] as? String, nickname != "##nil##" {
            self.nickname = nickname
        } else {
            self.nickname = nil
        }
    }
}
