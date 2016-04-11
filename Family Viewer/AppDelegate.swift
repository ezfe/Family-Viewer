//
//  AppDelegate.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa
import AppKit
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /*
     * Version to save in the file
     * 1: Current version as of Build 759
     */
    let formatVersion = 2
    var tree = Tree()

    //MARK:- PDF DEMO
    @IBAction func generatePDF(sender: AnyObject) {
        let aPDFDocument = PDFDocument()
        
        let today = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        let convertedDate = dateFormatter.stringFromDate(today)
        
        let coverPage = CoverPDFPage(hasMargin: true,
                                     title: "Family Tree Report",
                                     creditInformation: "Created By: Family Viewer \r \(convertedDate)",
                                     headerText: tree.treeName,
                                     footerText: "ezekielelin.com/family-viewer",
                                     pageWidth: CGFloat(900.0),
                                     pageHeight: CGFloat(1200.0),
                                     hasPageNumber: true,
                                     pageNumber: 1)
        
        
        
        aPDFDocument.insertPage(coverPage, atIndex: 0)
        
        for i in 0..<tree.people.count {
            
            let tabularDataPDF = FamilyDetail(hasMargin: true,
                                                 headerText: "confidential info...",
                                                 footerText: "www.knowstack.com",
                                                 pageWidth: CGFloat(850),
                                                 pageHeight: CGFloat(1100),
                                                 hasPageNumber: true,
                                                 pageNumber: i+1,
                                                 person: tree.people[i  ])
            
            aPDFDocument.insertPage(tabularDataPDF, atIndex: i+1)
        }
        
        aPDFDocument.writeToFile("/Users/ezekielelin/Desktop/sample1.pdf")
    }
    //MARK:-
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        guard let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else {
            displayAlert("Error", message: "No application version")
            NSApp.terminate(self)
            return
        }
        
        let verificationURL = "https://ezekielelin.com/family-viewer/beta-verification?v=\(appVersion)"
        if let verificationURL = NSURL(string: verificationURL) {
            do {
                let myHTMLString = try NSString(contentsOfURL: verificationURL, encoding: NSUTF8StringEncoding)

                if myHTMLString != "OK" {
                    displayAlert("Error", message: "This build cannot run due to an unexpected server response\n\nYou may need to update this application to continue using it")
                    NSApp.terminate(self)
                }
            } catch {
                displayAlert("Error", message: "An unexpected error occured making a network request")
            }

        } else {
            fatalError("Verification URL is not valid")
        }

        //Create AppSupport directory if it doesn't exist already
        createAppSupportFolder()

        let fm = NSFileManager.defaultManager()
        
        if let fpath = dataFileURL.path {
            if !fm.fileExistsAtPath(fpath) {
                saveFile(self)
            } else {
                readSavedData(dataFileURL.path!)
            }
        } else {
            displayAlert("Error", message: "Unable to get data file path")
            NSApp.terminate(self)
            return
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
        guard let fpath = dataFileURL.path else {
            print("Warning: dataFileURL.path is nil at \(#function) on line \(#line)")
            return false
        }
        return fm.fileExistsAtPath(fpath)
    }
    
    @IBAction func saveFile(sender: AnyObject) {
        createAppSupportFolder()
        let fm = NSFileManager.defaultManager()
        if tree.realTree {
            tree.dictionary.writeToFile(dataFilePath, atomically: true)
            
            if !fm.fileExistsAtPath(dataFilePath) {
                print("File wasn't written for unknown reason")
                print(tree.dictionary)
            }
        } else {
            print("Tree wasn't written because it's not real")
        }
    }

    @IBAction func addPerson(sender: AnyObject) {
        let p = Person(tree: tree)
        tree.people.append(p)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.showPerson", object: p)
    }
}
