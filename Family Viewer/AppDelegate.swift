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
    1: Current version as of Build 759
    */
    let formatVersion = 1    
    var tree = Tree()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let verificationURL = "http://ezekielelin.com/family-viewer/beta-verification?v=\(appVersion)"
        if let verificationURL = NSURL(string: verificationURL) {
            do {
                let myHTMLString = try NSString(contentsOfURL: verificationURL, encoding: NSUTF8StringEncoding)

                if myHTMLString != "OK" {
                    displayAlert("Error", message: "This build cannot run due to an unexpected server response\n\nReceived: \(myHTMLString)\nExpected: OK")
                    NSApp.terminate(self)
                }
            } catch {
                displayAlert("Error", message: "An unexpected error occured making a network request")
            }
            
        } else {
            fatalError("Verification URL is not valid")
        }
        
        createAppSupportFolder() //Create AppSupport directory if it doesn't exist already
        
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath(dataFileURL.path!) {
            saveFile(self)
        } else {
            readSavedData(dataFileURL.path!)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeIsReady", object: nil)
        
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
        saveFile(self)
        // Insert code here to tear down your application
    }
    
    func readSavedData(path: String) {
        let dict = NSDictionary(contentsOfFile: path)
        if let dict = dict, treeVersion = dict["version"] as? Int {
            if treeVersion > 0 {
                self.tree.loadDictionary(dict, appFormat: self.formatVersion)
            } else {
                fatalError("Version wasn't greater than 0")
            }
        } else {
            print("Error reading from path (\(path))")
        }
    }
    
    //MARK:-
    //MARK: Paths
    
    func appSupportURL() -> NSURL {
        let supportDirPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0]

        return NSURL(fileURLWithPath: supportDirPath).URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
    }
    
    func createAppSupportFolder() {
        do {
            let fm = NSFileManager.defaultManager()
            try fm.createDirectoryAtURL(appSupportURL(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Could not create directory at \(appSupportURL())")
        }
    }
    
    var dataFileURL: NSURL {
        get {
            return appSupportURL().URLByAppendingPathComponent("data.plist")
        }
    }
    
    var dataFilePath: String {
        get {
            guard let path = dataFileURL.path else {
                fatalError("Could not get dataFileURL")
            }
            return path
        }
    }
    
    //MARK:-
    
    func dataFileExists() -> Bool {
        let fm = NSFileManager.defaultManager()
        return fm.fileExistsAtPath(dataFileURL.path!)
    }
    
    @IBAction func saveFile(sender: AnyObject) {
        createAppSupportFolder()
        
        let fm = NSFileManager.defaultManager()
        
        tree.dictionary.writeToFile(dataFilePath, atomically: true)
        if !fm.fileExistsAtPath(dataFilePath) {
            print("File wasn't written for unknown reason")
            print(tree.dictionary)
        }
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.addPerson", object: nil)
    }
    @IBAction func deletePerson(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.deleteCurrentPerson", object: nil)
    }
}

