//
//  Family_Viewer_Tests.swift
//  Family Viewer Tests
//
//  Created by Ezekiel Elin on 9/5/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import XCTest

class Family_Viewer_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTree() {
        let tree = Tree()
        XCTAssert(tree.people.count == 0)
        
        let testName = "Test Name"
        
        let personA = Person(tree: tree)
        let personB = Person(tree: tree)
        let personC = Person(tree: tree)
        let personD = Person(tree: tree)
        tree.people.append(personA)
        tree.people.append(personB)
        tree.people.append(personC)
        tree.people.append(personD)
        
        personA.parentA = personB
        personA.parentB = personC
        personB.parentA = personD
        
        personA.nameAtBirth.familyName = testName
        XCTAssert(personD.children[0].children[0].nameAtBirth.familyName == testName)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
