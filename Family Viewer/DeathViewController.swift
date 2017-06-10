//
//  DeathViewController.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/23/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa
//import MapKit

class DeathViewController: NSViewController {

    var person: Person? = nil
    
    @IBOutlet weak var datePicker: NSTextField!
    @IBOutlet weak var monthPicker: NSPopUpButton!
    @IBOutlet weak var yearPicker: NSTextField!
    @IBOutlet weak var locationStringPicker: NSTextField!
    @IBOutlet weak var isAliveCheckbox: NSButton!
    
//    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let person = self.person {
            if let date = person.death.dateOfDeath.day {
                self.datePicker.integerValue = date
            } else {
                self.datePicker.stringValue = ""
            }
            if let month = person.death.dateOfDeath.month?.rawValue {
                self.monthPicker.selectItemWithTitle(month)
            } else {
                self.monthPicker.selectItemAtIndex(0)
            }
            if let year = person.death.dateOfDeath.year {
                self.yearPicker.integerValue = year
            } else {
                self.yearPicker.stringValue = ""
            }
            self.isAliveCheckbox.isChecked = person.isAlive
            self.locationStringPicker.stringValue = person.death.locationOfDeath
            
            self.update(self)
            
            updateMap()
        }
    }
    
    @IBAction func update(sender: AnyObject) {
        guard let person = person else {
            self.dismissController(self)
            return
        }
        
        if (isAliveCheckbox.isChecked) {
            isAliveCheckbox.title = "\(person.description) is alive"
            datePicker.enabled = false
            monthPicker.enabled = false
            yearPicker.enabled = false
            locationStringPicker.enabled = false
            
            person.isAlive = true
        } else {
            isAliveCheckbox.title = "\(person.description) is dead"
            datePicker.enabled = true
            monthPicker.enabled = true
            yearPicker.enabled = true
            locationStringPicker.enabled = true
            
            person.isAlive = false
        }
        
        let date = datePicker.integerValue
        if date <= 31 && date >= 1 {
            person.death.dateOfDeath.day = date
        } else {
            person.death.dateOfDeath.day = nil
            datePicker.stringValue = ""
        }
        
        if let month = monthPicker.titleOfSelectedItem {
            person.death.dateOfDeath.month = monthFromRaw(month: month)
        }
        
        let year = yearPicker.integerValue
        if year <= 3000 && year >= 1 {
            person.death.dateOfDeath.year = year
        } else {
            person.death.dateOfDeath.year = nil
            yearPicker.stringValue = ""
        }
        
        person.death.locationOfDeath = self.locationStringPicker.stringValue
        
        
        updateMap()
        NotificationCenter.default.post(name: .FVTreeDidUpdate, object: nil)
    }
    
    func updateMap() {
//        let geocoder: CLGeocoder = CLGeocoder()
//        guard let person = person else {
//            return
//        }
//        geocoder.geocodeAddressString(person.death.location, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
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
}
