//
//  TreeView.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 11/22/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

extension NSRect {
    var midpoint: NSPoint {
        get {
            return NSMakePoint(self.midX, self.midY)
        }
    }
    
    func rectCenteredAt(width width: CGFloat, height: CGFloat) -> NSRect {
        let midpoint = self.midpoint
        return NSMakeRect(midpoint.x - (width / 2), midpoint.y - (height / 2), width, height)
    }
}

func rectAround(centerX centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> NSRect {
    return NSMakeRect(centerX - (width / 2), centerY - (height / 2), width, height)
}

class TreeView: NSView {
    
    var tree: Tree = Tree()
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if let p = tree.selectedPerson {
            drawPerson(dirtyRect.midpoint.x, y: dirtyRect.midpoint.y, person: p, level: 1, drawParents: true, drawChildren: true)
        }
    }
    
    func drawPerson(x: CGFloat, y: CGFloat, person: Person, level: Int, drawParents: Bool, drawChildren: Bool) {
        let path = NSBezierPath(rect: rectAround(centerX: x, centerY: y, width: 10, height: 10))
        if person.sex == .Male {
            NSColor.blueColor().setFill()
        } else {
            NSColor.redColor().setFill()
        }
        path.fill()
        
        if drawParents {
            if let pa = person.parentA {
                let nx = x - (50 / CGFloat(level))
                drawPerson(nx, y: y + 22, person: pa, level: level + 1, drawParents: true, drawChildren: false)
            }
            if let pb = person.parentB {
                let nx = x + (50 / CGFloat(level))
                drawPerson(nx, y: y + 22, person: pb, level: level + 1, drawParents: true, drawChildren: false)
            }
        }
        if drawChildren {
            let children = person.children
            Swift.print(children)
            for (i, child) in children.enumerate() {
                let mx = ((CGFloat(i / 2) * 12) - (CGFloat(children.count / 2) * 12 / 2)) * CGFloat(abs(level));
                let nx: CGFloat
                if (i < children.count / 2) {
                    nx = x - mx
                } else {
                    nx = x + mx
                }
                drawPerson(nx, y: y - 22, person: child, level: level - 1, drawParents: false, drawChildren: true)
            }
        }

    }
}
