//
//  NotificationTypes.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 6/10/17.
//  Copyright © 2017 Ezekiel Elin. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let FVTreeDidUpdate = NSNotification.Name("com.ezekielelin.treeDidUpdate")
    public static let FVTreeIsReady = NSNotification.Name("com.ezekielelin.treeIsReady")
    public static let FVAddedParent = NSNotification.Name("com.ezekielelin.addedParent")
    public static let FVShowPerson = NSNotification.Name("com.ezekielelin.showPerson")
}

