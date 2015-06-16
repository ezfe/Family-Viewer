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
            let fm = NSFileManager()
            if fm.fileExistsAtPath(NSURL(string: filePath)!.path!) {
                if filePath.rangeOfString(".ged") != nil {
                    readGEDFile(NSURL(string: filePath)!)
                } else {
                    readXMLFile(NSURL(string: filePath)!)
                }
            } else {
                print("Hmm...couldn't find \(NSURL(string: filePath)!.path!)")
                defaults.removeObjectForKey("filePath")
            }
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
        fileDialog.allowedFileTypes = ["ged"]
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
    
    func readXMLFile(url: NSURL) {
        let path = url.path!
        let dict = NSArray(contentsOfFile: path)
        if let dict = dict {
            self.tree = Tree(array: dict)
        } else {
            print("Error reading from path (\(path))")
        }
    }
    
    @IBAction func openXMLFile(sender: AnyObject) {
        let fileDialog = NSOpenPanel()
        
        fileDialog.prompt = "Open XML File"
        fileDialog.allowsMultipleSelection = false
        fileDialog.canChooseDirectories = false
        fileDialog.canChooseFiles = true
        fileDialog.resolvesAliases = true
        fileDialog.allowedFileTypes = ["xml"]
        fileDialog.runModal()
        if let fileURL = fileDialog.URL {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(fileURL.absoluteString, forKey: "filePath")
            
            print("Stored defaults as \(fileURL.absoluteString)")
            
            readXMLFile(fileURL)
        } else {
            print("No path, not importing anything")
        }
    }
    
    @IBAction func saveFile(sender: AnyObject) {
        let fileDialog = NSSavePanel()
        fileDialog.allowedFileTypes = ["xml"]
        fileDialog.runModal()
        if let filePath = fileDialog.URL?.path {
            tree.dictionary.writeToFile(filePath, atomically: true)
        } else {
            print("No path, not importing anything")
        }
    }
}

