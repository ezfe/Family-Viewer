//
//  PersonBrowserSidebar.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 7/26/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class PersonBrowserSidebarDataSource: NSObject, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.tree.people.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
//        print("getting person for row \(row)")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let person = appDelegate.tree.people[row]
        
        return person.description
    }
}

class PersonBrowserSidebarDelegate: NSObject, NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, didClickTableColumn tableColumn: NSTableColumn) {
        displayAlert("Error", message: "That button doesn't do  what it should")
        //TODO: Find a way to intercept and cancel this event
    }
}