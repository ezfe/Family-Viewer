//
//  BirthdayViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/23/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa
//import MapKit

class BirthdayViewController: NSViewController {

    var person: Person? = nil
    
    @IBOutlet weak var datePicker: NSTextField!
    @IBOutlet weak var monthPicker: NSPopUpButton!
    @IBOutlet weak var yearPicker: NSTextField!
//    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationStringPicker: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let person = self.person {
            if let date = person.birth.date.day {
                self.datePicker.integerValue = date
            } else {
                self.datePicker.stringValue = ""
            }
            if let month = person.birth.date.month?.rawValue {
                self.monthPicker.selectItemWithTitle(month)
            } else {
                self.monthPicker.selectItemAtIndex(0)
            }
            if let year = person.birth.date.year {
                self.yearPicker.integerValue = year
            } else {
                self.yearPicker.stringValue = ""
            }
            self.locationStringPicker.stringValue = person.birth.location

            updateMap()
        }
    }
    
    func updateMap() {
//        let geocoder: CLGeocoder = CLGeocoder()
//        guard let person = person else {
//            return
//        }
//        geocoder.geocodeAddressString(person.birth.location, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
//            guard let placemarks = placemarks else {
//                return
//            }
//            let place = placemarks[0]
//            let location = place.location!;
//            //TODO: This seems like a silly thing to do to avoid "deprecated"
//            let region = place.region! as! CLCircularRegion;
//            centerMapOnLocation(self.map, location: location, radius: region.radius)
//        })
    }
    
    @IBAction func update(sender: AnyObject) {
        guard let person = person else {
            self.dismissController(self)
            return
        }
        
        let date = datePicker.integerValue
        if date <= 31 && date >= 1 {
            person.birth.date.day = date
        } else {
            person.birth.date.day = nil
            datePicker.stringValue = ""
        }
        
        if let month = monthPicker.titleOfSelectedItem {
            person.birth.date.month = monthFromRaw(month: month)
        }
        
        let year = yearPicker.integerValue
        if year <= 3000 && year >= 1 {
            person.birth.date.year = year
        } else {
            person.birth.date.year = nil
            yearPicker.stringValue = ""
        }
        
        person.birth.location = self.locationStringPicker.stringValue
        
        updateMap()
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.ezekielelin.treeDidUpdate", object: nil)
    }
}
