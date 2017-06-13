//
//  String+Subscripts.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/11/17.
//  Copyright © 2017 Ezekiel Elin. All rights reserved.
//

import Foundation

extension String {
    @available(*, deprecated: 0.9.0, message: "Use proper string methods")
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    @available(*, deprecated: 0.9.0, message: "Use proper string methods")
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    @available(*, deprecated: 0.9.0, message: "Use proper string methods")
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)
        let range = Range(start ..< end)
        return substring(with: range)
    }
}
