//
//  AppDelegate.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /*
     * Version to save in the file
     * 1: Current version as of Build 759
     */
    let formatVersion = 3
    var tree = Tree()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            displayAlert(title: "Error", message: "No application version")
            NSApp.terminate(self)
            return
        }
        
        let verificationURL = "https://ezekielelin.com/family-viewer/beta-verification?v=\(appVersion)"
        if let verificationURL = URL(string: verificationURL) {
            do {
                let myHTMLString = try String.init(contentsOf: verificationURL)
                
                if myHTMLString != "OK" {
                    displayAlert(title: "Error", message: "This build cannot run due to an unexpected server response\n\nYou may need to update this application to continue using it")
                    NSApp.terminate(self)
                }
            } catch {
                displayAlert(title: "Error", message: "An unexpected error occured making a network request")
            }
            
        } else {
            fatalError("Verification URL is not valid")
        }
        
        //Create AppSupport directory if it doesn't exist already
        createAppSupportFolder()
        
        let fm = FileManager.default
        
        let fpath = dataFileURL.path
        if !fm.fileExists(atPath: fpath) {
            saveFile(self)
        } else {
            readSavedData(path: dataFileURL.path)
        }
        
        NotificationCenter.default.post(name: .FVTreeIsReady, object: nil)
        
        let defaults = UserDefaults.standard
        var showAlert = true
        if defaults.bool(forKey: "betaAlertShown") {
            showAlert = false
        }
        if showAlert {
            displayAlert(title: "Notice!", message: "This is a beta build. Saved files may not be compatible with future versions, data loss may occur.")
        }
        defaults.set(true, forKey: "betaAlertShown")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        saveFile(self)
    }
    
    func readSavedData(path: String) {
        let dict = NSDictionary(contentsOfFile: path)
        if let dict = dict, let treeVersion = dict["version"] as? Int {
            if treeVersion > 0 {
                guard let mutableDict = dict.mutableCopy() as? NSMutableDictionary else {
                    return
                }
                self.tree.loadDictionary(dict: mutableDict, appFormat: self.formatVersion)
            } else {
                fatalError("Version wasn't greater than 0")
            }
        } else {
            print("Error reading from path (\(path))")
        }
    }
    
    //MARK:-
    //MARK: Paths
    
    func appSupportURL() -> URL {
        let supportDirPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        
        return URL(fileURLWithPath: supportDirPath).appendingPathComponent(Bundle.main.bundleIdentifier!)
    }
    
    func createAppSupportFolder() {
        do {
            let fm = FileManager.default
            try fm.createDirectory(at: appSupportURL(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Could not create directory at \(appSupportURL())")
        }
    }
    
    var dataFileURL: URL {
        get {
            return appSupportURL().appendingPathComponent("data.plist")
        }
    }
    
    var dataFilePath: String {
        get {
            return dataFileURL.path
        }
    }
    
    //MARK:-
    
    func dataFileExists() -> Bool {
        let fm = FileManager.default
        let fpath = dataFileURL.path
        return fm.fileExists(atPath: fpath)
    }
    
    @IBAction func saveFile(_ sender: AnyObject) {
        createAppSupportFolder()
        let fm = FileManager.default
        if tree.realTree {
            tree.dictionary.write(to: dataFileURL, atomically: true)
            
            if !fm.fileExists(atPath: dataFilePath) {
                print("File wasn't written for unknown reason")
                print(tree.dictionary)
            }
        } else {
            print("Tree wasn't written because it's not real")
        }
    }
    
    @IBAction func addPerson(_ sender: AnyObject) {
        let p = Person(tree: tree)
        tree.people.append(p)
        NotificationCenter.default.post(name: .FVTreeDidUpdate, object: nil)
        NotificationCenter.default.post(name: .FVShowPerson, object: p)
    }
}
