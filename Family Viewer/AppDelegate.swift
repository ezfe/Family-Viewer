//
//  AppDelegate.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    var tree = Tree() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        }
    }
    
    @IBAction func openGEDFile(sender: AnyObject) {
        let fileDialog = NSOpenPanel()
        
        fileDialog.prompt = "Convert GEDCOM File"
        fileDialog.allowsMultipleSelection = false
        fileDialog.canChooseDirectories = false
        fileDialog.canChooseFiles = true
        fileDialog.resolvesAliases = true
        fileDialog.runModal()
        if let fileURL = fileDialog.URL {
            let stringData = try! NSString(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
            let t = GEDCOMToFamilyObject(gedcomString: stringData as String)
            if t.people.count > 0 {
                self.tree = t
            } else {
                print("No people in tree, ignoring")
            }
        } else {
            print("No path, not importing anything")
        }
    }
    
    @IBAction func openXMLFile(sender: AnyObject) {
    }
    
    @IBAction func saveFile(sender: AnyObject) {
    }
}

