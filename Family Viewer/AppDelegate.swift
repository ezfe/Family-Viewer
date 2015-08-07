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
        
        //
        let defaults = NSUserDefaults.standardUserDefaults()
        var showAlert = true
        if defaults.boolForKey("betaAlertShown") {
            showAlert = false
        }
        if showAlert {
            let alert = NSAlert()
            alert.messageText = "Notice!"
            alert.informativeText = "This is a beta build. Saved files may not be compatible with future versions, data loss may occur."
            alert.runModal()
            let alert2 = NSAlert()
            alert2.messageText = "Also..."
            alert2.informativeText = "These are the only alerts in the entire app. If you press a button and nothing happens, check the Console"
            alert2.runModal()
        }
        defaults.setBool(true, forKey: "betaAlertShown")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openLastFile", name: "com.ezekielelin.openLastFile", object: nil)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    var hasTree = false
    
    var tree = Tree() {
        didSet {
            assert(self.hasTree, "hasTree is false, yet self.tree was set?")
            NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        }
    }
    
    func openLastFile() {
        print("Received notification to open last file...")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let filePath = defaults.stringForKey("filePath") {
            print("Reading from path...")
            let fm = NSFileManager()
            if fm.fileExistsAtPath(filePath) {
                if filePath.rangeOfString(".ged") != nil {
                    readGEDFile(filePath)
                } else {
                    readXMLFile(filePath)
                }
            } else {
                print("Hmm...couldn't find \(filePath)")
                defaults.removeObjectForKey("filePath")
                NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.updatedDefaults_FilePath", object: nil)
            }
        } else {
            print("Unable to read from path...")
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
        if let fileURL = fileDialog.URL?.path {
            //            let defaults = NSUserDefaults.standardUserDefaults()
            //            defaults.setObject(fileURL.path!, forKey: "filePath")
            
            print("Didn't store default, because GEDCOM files shouldn't be saved")
            //            print(defaults.stringForKey("filePath"))
            
            readGEDFile(fileURL)
        } else {
            print("No path, not importing anything")
        }
    }
    
    func readGEDFile(path: String) {
        displayAlert("Warning!", message: "This will overwrite your current tree with the data from the GED file")
        let stringData = try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        let t = GEDCOMToFamilyObject(gedcomString: stringData as String)
        if t.people.count > 0 {
            self.hasTree = true
            self.tree = t
        } else {
            print("No people in tree, ignoring")
        }
    }
    
    func readXMLFile(path: String) {
        let dict = NSDictionary(contentsOfFile: path)
        if let dict = dict, treeVersion = dict["version"] as? Int {
            if treeVersion > 0 {
                self.hasTree = true
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

