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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let filePath = defaults.stringForKey("filePath") {
            print("Reading from path...")
            readGEDFile(NSURL(string: filePath)!)
        } else {
            print("Unable to read from path...")
        }
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
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(fileURL.absoluteString, forKey: "filePath")
            
            print("Stored defaults")
            print(defaults.stringForKey("filePath"))
            
            readGEDFile(fileURL)
        } else {
            print("No path, not importing anything")
        }
    }
    
    func readGEDFile(path: NSURL) {
        let stringData = try! NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
        let t = GEDCOMToFamilyObject(gedcomString: stringData as String)
        if t.people.count > 0 {
            self.tree = t
        } else {
            print("No people in tree, ignoring")
        }
    }
    
    @IBAction func openXMLFile(sender: AnyObject) {
    }
    
    @IBAction func saveFile(sender: AnyObject) {
    }
}

