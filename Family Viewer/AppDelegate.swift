//
//  AppDelegate.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa
//import Foundation
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /**
    Version to save in the file
    1: Current version as of Build 445
    */
    let formatVersion = 1
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Make sure app folder exists
        
        createAppSupportFolder() //Create AppSupport directory if it doesn't exist already
        
        let fm = NSFileManager.defaultManager()
        
        if !fm.fileExistsAtPath(dataFileURL().path!) {
            saveFile(self)
        } else {
            readXMLFile(dataFileURL().path!)
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var showAlert = true
        if defaults.boolForKey("betaAlertShown") {
            showAlert = false
        }
        if showAlert {
            displayAlert("Notice!", message: "This is a beta build. Saved files may not be compatible with future versions, data loss may occur.")
        }
        defaults.setBool(true, forKey: "betaAlertShown")
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
        displayAlert("Notice", message: "GED File reading is currently disabled");
//        let fileDialog = NSOpenPanel()
//        
//        fileDialog.prompt = "Convert GEDCOM File"
//        fileDialog.allowsMultipleSelection = false
//        fileDialog.canChooseDirectories = false
//        fileDialog.canChooseFiles = true
//        fileDialog.resolvesAliases = true
//        fileDialog.allowedFileTypes = ["ged"]
//        fileDialog.runModal()
//        if let fileURL = fileDialog.URL?.path {
//            //            let defaults = NSUserDefaults.standardUserDefaults()
//            //            defaults.setObject(fileURL.path!, forKey: "filePath")
//            
//            print("Didn't store default, because GEDCOM files shouldn't be saved")
//            //            print(defaults.stringForKey("filePath"))
//            
//            readGEDFile(fileURL)
//        } else {
//            print("No path, not importing anything")
//        }
    }
    
    func readGEDFile(path: String) {
        displayAlert("Notice", message: "GED File reading is currently disabled");
//        displayAlert("Warning!", message: "This will overwrite your current tree with the data from the GED file")
//        let stringData = try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//        let t = GEDCOMToFamilyObject(gedcomString: stringData as String)
//        if t.people.count > 0 {
//            self.hasTree = true
//            self.tree = t
//        } else {
//            print("No people in tree, ignoring")
//        }
    }
    
    func readXMLFile(path: String) {
        let dict = NSDictionary(contentsOfFile: path)
        if let dict = dict, treeVersion = dict["version"] as? Int {
            if treeVersion > 0 {
                self.tree = Tree(dictionary: dict)
            } else {
                assert(false,"Version wasn't greater than 0")
            }
        } else {
            print("Error reading from path (\(path))")
        }
    }
    
    func appSupportURL() -> NSURL {
        let supportDirPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0]

        return NSURL(fileURLWithPath: supportDirPath).URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
    }
    
    func createAppSupportFolder() {
        let fm = NSFileManager.defaultManager()
        try! fm.createDirectoryAtURL(appSupportURL(), withIntermediateDirectories: true, attributes: nil)
    }
    
    func dataFileURL() -> NSURL {
        return appSupportURL().URLByAppendingPathComponent("data.xml")
    }
    
    func dataFileExists() -> Bool {
        let fm = NSFileManager.defaultManager()
        return fm.fileExistsAtPath(dataFileURL().path!)
    }
    
    @IBAction func saveFile(sender: AnyObject) {
        createAppSupportFolder()
        
        let fm = NSFileManager.defaultManager()
        tree.dictionary.writeToFile(dataFileURL().path!, atomically: true)
        if !fm.fileExistsAtPath(dataFileURL().path!) {
            print("File wasn't written for unknown reason")
            print(tree.dictionary)
        }

        
        displayAlert("Success", message: "The file was saved or created")
//        let fileDialog = NSSavePanel()
//        fileDialog.allowedFileTypes = ["xml"]
//        fileDialog.runModal()
//        if let filePath = fileDialog.URL?.path {
//            let defaults = NSUserDefaults.standardUserDefaults()
//            defaults.setObject(filePath, forKey: "filePath")
//            
//            tree.dictionary.writeToFile(filePath, atomically: true)
//            
//        } else {
//            print("No path, not importing anything")
//        }
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.addPerson", object: nil)
    }
    @IBAction func deletePerson(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.deleteCurrentPerson", object: nil)
    }
}

