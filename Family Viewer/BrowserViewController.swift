//
//  BrowserViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 4/10/16.
//  Copyright © 2016 Ezekiel Elin. All rights reserved.
//

import Cocoa

class BrowserViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    ///The tree
    var tree: Tree? = nil
    
    @IBOutlet weak var mainBrowserTable: NSTableView!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadTree), name: "com.ezekielelin.treeIsReady", object: nil)

        
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadTree() {
        print("Loading tree...")

        guard let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate else {
            print("\(#function)@\(#line): unable to find App Delegate")
            return
        }

        self.tree = appDelegate.tree

        guard let tree = self.tree else {
            print("\(#function)@\(#line): self.tree is nil")
            return
        }

        if let selectedPersonFromTree = tree.selectedPerson {
            //TODO: Replace this
//            selectPerson(person: selectedPersonFromTree)
        } else {
            if tree.people.count == 0 {
                tree.people.append(Person(tree: tree))
            }
            //TODO: And this
//            selectPerson(person: tree.people[0])
        }
        
        mainBrowserTable.reloadData()
        
    }
    
    func updateTable() {
        mainBrowserTable.reloadData()
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            //TODO: Move this to another function, causes false selections
            //TODO: Select Person
//            selectPerson(person: tree!.people[row], isFromTable: true)
            return true
        case .ChildrenTable, .ParentsTable:
            return true
        }
    }
    
    @IBAction func tableClick(sender: AnyObject) {
        if let tree = self.tree where mainBrowserTable.selectedRow != -1 {
            viewPerson(tree.people[mainBrowserTable.selectedRow])
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let tree = self.tree {
            return tree.people.count
        } else {
            return 0
        }
    }
    
    /**
     This function manages the table view and and populates it with the necessary values.
     */
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch getXcodeTag(tableView.tag) {
        case .MainBrowserTable:
            guard let v = tableView.makeViewWithIdentifier("PersonCell", owner: self) as? NSTableCellView else {
                return nil
            }
            
            guard let tree = self.tree else {
                treeIsNilError()
                return nil
            }
            
            v.textField?.stringValue = tree.people[row].description
            
            return v
        default:
            return nil
        }
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
        if let tree = self.tree {
            tree.sortPeople(tree.nextSort)
            mainBrowserTable.reloadData()
        } else {
            treeIsNilError()
        }
        
        return false
    }
    
    func viewPerson(person: Person) {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("MainViewController") as? ViewController {
            vc.person = person
            
            self.presentViewController(vc, asPopoverRelativeToRect: mainBrowserTable.visibleRect, ofView: mainBrowserTable, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Semitransient)

        }
    }
    
}
