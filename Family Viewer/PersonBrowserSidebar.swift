//
//  PersonBrowserSidebar.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 7/26/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class PersonBrowserSidebarViewController: NSViewController {
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "treeUpdate", name: "com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popupRowChange:", name: "com.ezekielelin.popupRowChange", object: nil)

    }
    
    @IBAction func click(sender: AnyObject) {
        if table.selectedRow == -1 {
            return
        }
        print("Sending notification with new row: \(table.selectedRow)")
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.sidebarTableRowChange", object: nil, userInfo: ["row": table.selectedRow])
    }
    
    func treeUpdate() {
        table.reloadData()
    }
    
    func popupRowChange(notification: NSNotification) {
        
        let row = notification.userInfo!["row"] as! Int
        
        let indexes = NSIndexSet(index: row)
        table.selectRowIndexes(indexes, byExtendingSelection: false)
    }
}

class PersonBrowserSidebarDataSource: NSObject, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.hasTree ? appDelegate.tree.people.count : 0
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