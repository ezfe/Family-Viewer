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
    }
    
    func treeUpdate() {
        table.reloadData()
    }
}

class PersonBrowserSidebarDataSource: NSObject, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.hasTree ? appDelegate.tree.people.count : 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        print("getting person for row \(row)")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.hasTree ? appDelegate.tree.people[row] : nil
    }
}