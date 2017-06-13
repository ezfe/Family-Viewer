//
//  NSButton+IsChecked.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/11/17.
//  Copyright © 2017 Ezekiel Elin. All rights reserved.
//

import Cocoa

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
