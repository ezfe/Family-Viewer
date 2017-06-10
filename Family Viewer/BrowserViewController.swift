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
    var windowControllers = Dictionary<Int, NSWindowController>()
    
    override func viewDidLoad() {
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadTree), name: "com.ezekielelin.treeIsReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTable), name: "com.ezekielelin.treeDidUpdate", object: nil)
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(addedParent(_:)), name: "com.ezekielelin.addedParent", object: nil)
        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(showPerson(_:)), name: "com.ezekielelin.showPerson", object: nil)
        
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadTree() {
        print("Loading tree...")
        
        guard let appDelegate = NSApplication.shared().delegate as? AppDelegate else {
            print("\(#function)@\(#line): unable to find App Delegate")
            return
        }
        
        self.tree = appDelegate.tree
        
        mainBrowserTable.reloadData()
        
        tree?.describe()
        print("*: May not be exhaustive")
    }
    
    func addedParent(notification: NSNotification) {
        if let p = notification.userInfo?["newPerson"] as? Person {
            viewPerson(person: p)
        }
    }
    
    func updateTable() {
        mainBrowserTable.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        switch getXcodeTag(tag: tableView.tag) {
        case .MainBrowserTable:
            //TODO: Move this to another function, causes false selections
            //TODO: Select Person
            //            selectPerson(person: tree!.people[row], isFromTable: true)
            return true
        default:
            return true
        }
    }
    
    @IBAction func tableClick(sender: AnyObject) {
        if let tree = self.tree, mainBrowserTable.selectedRow != -1 {
            for i in mainBrowserTable.selectedRowIndexes {
                viewPerson(person: tree.people[i])
            }
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
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch getXcodeTag(tag: tableView.tag) {
        case .MainBrowserTable:
            guard let v = tableView.make(withIdentifier: "PersonCell", owner: self) as? NSTableCellView else {
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
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        if let tree = self.tree {
            tree.sortPeople(sortType: tree.nextSort)
            mainBrowserTable.reloadData()
        } else {
            treeIsNilError()
        }
        
        return false
    }
    
    func viewPerson(person: Person) {
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("MainViewController") as? PersonDetailViewController {
            vc.person = person
            
            if let wc = windowControllers[person.INDI] {
                wc.window?.makeKeyAndOrderFront(self)
            } else {
                
                let myWindow = NSWindow(contentViewController: vc)
                myWindow.makeKeyAndOrderFront(self)
                let wc = NSWindowController(window: myWindow)
                
                //TODO: Cascade
                
                wc.showWindow(self)
                
                //TODO: Do this better
                windowControllers[person.INDI] = wc
            }
        }
    }
    
    func showPerson(notification: NSNotification) {
        if let p = notification.object as? Person {
            viewPerson(p)
        }
    }
    
}
