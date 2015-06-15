//
//  Document.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/14/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        
        makeWindowControllers()
        
        guard let tree = self.windowControllers[0].contentViewController?.representedObject as? Tree  else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        let archiver = NSKeyedArchiver()
        archiver.encodeObject(tree)
//        NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        
        guard let dataString = NSString(data:data, encoding:NSUTF8StringEncoding) as? String else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        makeWindowControllers()
        self.windowControllers[0].contentViewController?.representedObject = GEDCOMToFamilyObject(gedcomString: dataString)
    }
}

