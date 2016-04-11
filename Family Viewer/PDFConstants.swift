//  PDFConstants.swift
//  SwiftPDFGeneration
//  Created by Debasis Das on 01/02/16.
//  Copyright © 2016 Knowstack. All rights reserved.

import Foundation
import Quartz

let defaultRowHeight = CGFloat(23.0)
let defaultColumnWidth = CGFloat(150.0)
let numberOfRowsPerPage = 50
let topMargin = CGFloat(40.0)
let leftMargin = CGFloat(20.0)
let rightMargin = CGFloat(20.0)
let bottomMargin = CGFloat (40.0)
let textInset = CGFloat(5.0)
let verticalPadding = CGFloat (10.0)

class BasePDFPage: PDFPage {
    
    var hasMargin = true
    var headerText = "Default Header Text"
    var footerText = "Default Footer Text"
    
    var hasPageNumber = true
    var pageNumber = 1
    
    var pdfHeight = CGFloat(1100) //This is configurable
    var pdfWidth = CGFloat(850)   //This is configurable and is calculated based on the number of columns
    
    func drawLine(X1 fromX: CGFloat, Y1 fromY: CGFloat, X2 toX: CGFloat, Y2 toY: CGFloat) {
        drawLine(NSMakePoint(fromX, fromY), toPoint: NSMakePoint(toX, toY))
    }
    
    func drawLine(fromPoint: NSPoint, toPoint: NSPoint) {
        let path = NSBezierPath()
        NSColor.lightGrayColor().set()
        path.moveToPoint(fromPoint)
        path.lineToPoint(toPoint)
        path.lineWidth = 0.5
        path.stroke()
    }
    
    func drawHeader() {
        let headerTextX = leftMargin
        let headerTextY = self.pdfHeight - CGFloat(35.0)
        let headerTextWidth = self.pdfWidth - leftMargin - rightMargin
        let headerTextHeight = CGFloat(20.0)
        
        let headerFont = NSFont(name: "Helvetica", size: 15.0)
        
        let headerParagraphStyle = NSMutableParagraphStyle()
        headerParagraphStyle.alignment = NSRightTextAlignment
        
        let headerFontAttributes = [
            NSFontAttributeName: headerFont ?? NSFont.labelFontOfSize(12),
            NSParagraphStyleAttributeName:headerParagraphStyle,
            NSForegroundColorAttributeName:NSColor.lightGrayColor()
        ]
        let headerRect = NSMakeRect(headerTextX, headerTextY, headerTextWidth, headerTextHeight)
        self.headerText.drawInRect(headerRect, withAttributes: headerFontAttributes)
    }
    
    func drawFooter() {
        let footerTextX = leftMargin
        let footerTextY = CGFloat(15.0)
        let footerTextWidth = self.pdfWidth / 2.1
        let footerTextHeight = CGFloat(20.0)
        
        let footerFont = NSFont(name: "Helvetica", size: 15.0)
        
        let footerParagraphStyle = NSMutableParagraphStyle()
        footerParagraphStyle.alignment = NSLeftTextAlignment
        
        let footerFontAttributes = [
            NSFontAttributeName: footerFont ?? NSFont.labelFontOfSize(12),
            NSParagraphStyleAttributeName:footerParagraphStyle,
            NSForegroundColorAttributeName:NSColor.lightGrayColor()
        ]
        
        let footerRect = NSMakeRect(footerTextX, footerTextY, footerTextWidth, footerTextHeight)
        self.footerText.drawInRect(footerRect, withAttributes: footerFontAttributes)
    }
    
    func drawMargins() {
        let borderLine = NSMakeRect(leftMargin, bottomMargin, self.pdfWidth - leftMargin - rightMargin, self.pdfHeight - topMargin - bottomMargin)
        NSColor.grayColor().set()
        NSFrameRectWithWidth(borderLine, 0.5)
    }
    
    func drawPageNumbers () {
        let pageNumTextX = self.pdfWidth/2
        let pageNumTextY = CGFloat(15.0)
        let pageNumTextWidth = CGFloat(40.0)
        let pageNumTextHeight = CGFloat(20.0)
        
        let pageNumFont = NSFont(name: "Helvetica", size: 15.0)
        
        let pageNumParagraphStyle = NSMutableParagraphStyle()
        pageNumParagraphStyle.alignment = NSCenterTextAlignment
        
        let pageNumFontAttributes = [
            NSFontAttributeName: pageNumFont ?? NSFont.labelFontOfSize(12),
            NSParagraphStyleAttributeName:pageNumParagraphStyle,
            NSForegroundColorAttributeName: NSColor.darkGrayColor()
        ]
        
        let pageNumRect = NSMakeRect(pageNumTextX, pageNumTextY, pageNumTextWidth, pageNumTextHeight)
        let pageNumberStr = "\(self.pageNumber)"
        pageNumberStr.drawInRect(pageNumRect, withAttributes: pageNumFontAttributes)
        
    }
    
    override func boundsForBox(box: PDFDisplayBox) -> NSRect {
        return NSMakeRect(0, 0, pdfWidth, pdfHeight)
    }
    
    override func drawWithBox(box: PDFDisplayBox) {
        if hasPageNumber{
            self.drawPageNumbers()
        }
        if hasMargin{
            self.drawMargins()
        }
        if headerText.characters.count > 0 {
            self.drawHeader()
        }
        if footerText.characters.count > 0{
            self.drawFooter()
        }
    }
    
    init(hasMargin:Bool, headerText:String, footerText:String, pageWidth:CGFloat, pageHeight:CGFloat, hasPageNumber:Bool, pageNumber:Int) {
        super.init()
        self.hasMargin = hasMargin
        self.headerText = headerText
        self.footerText = footerText
        self.pdfWidth = pageWidth
        self.pdfHeight = pageHeight
        self.hasPageNumber = hasPageNumber
        self.pageNumber = pageNumber
    }
    
}

//The Cover Page for the PDF Document
class CoverPDFPage: BasePDFPage {
    var pdfTitle:NSString = "Default PDF Title"
    var creditInformation = "Default Credit Information"
    
    init(hasMargin:Bool, title:String, creditInformation:String, headerText:String, footerText:String, pageWidth:CGFloat, pageHeight:CGFloat, hasPageNumber:Bool, pageNumber:Int) {
        super.init(hasMargin: hasMargin, headerText: headerText, footerText: footerText, pageWidth: pageWidth, pageHeight: pageHeight, hasPageNumber: hasPageNumber, pageNumber: pageNumber)
        
        self.pdfTitle = title
        self.creditInformation = creditInformation
    }
    
    func drawPDFTitle() {
        let pdfTitleX = 1/4 * self.pdfWidth
        let pdfTitleY = self.pdfHeight / 2
        let pdfTitleWidth = 1/2 * self.pdfWidth
        let pdfTitleHeight = 1/5 * self.pdfHeight
        let titleFont = NSFont(name: "Helvetica Bold", size: 30.0)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSCenterTextAlignment
        
        let titleFontAttributes = [
            NSFontAttributeName: titleFont ?? NSFont.labelFontOfSize(12),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: NSColor.blueColor()
        ]
        
        let titleRect = NSMakeRect(pdfTitleX, pdfTitleY, pdfTitleWidth, pdfTitleHeight)
        self.pdfTitle.drawInRect(titleRect, withAttributes: titleFontAttributes)
    }
    
    func drawPDFCreditInformation() {
        let pdfCreditX = 1/4 * self.pdfWidth
        let pdfCreditY = self.pdfHeight / 2 - 1/5 * self.pdfHeight
        let pdfCreditWidth = 1/2 * self.pdfWidth
        let pdfCreditHeight = CGFloat(40.0)
        let creditFont = NSFont(name: "Helvetica", size: 15.0)
        
        let creditParagraphStyle = NSMutableParagraphStyle()
        creditParagraphStyle.alignment = NSCenterTextAlignment
        
        let creditFontAttributes = [
            NSFontAttributeName: creditFont ?? NSFont.labelFontOfSize(12),
            NSParagraphStyleAttributeName:creditParagraphStyle,
            NSForegroundColorAttributeName: NSColor.darkGrayColor()
        ]
        
        let creditRect = NSMakeRect(pdfCreditX, pdfCreditY, pdfCreditWidth, pdfCreditHeight)
        self.creditInformation.drawInRect(creditRect, withAttributes: creditFontAttributes)
        
    }
    
    override func drawWithBox(box: PDFDisplayBox) {
        super.drawWithBox(box)
        self.drawPDFTitle()
        self.drawPDFCreditInformation()
    }
    
}

//Tabular PDF Page
class FamilyDetail: BasePDFPage {
    var person: Person
    var verticalPadding = CGFloat(10.0)
    
    init(hasMargin:Bool, headerText:String, footerText:String, pageWidth:CGFloat, pageHeight:CGFloat, hasPageNumber:Bool, pageNumber:Int, person: Person) {
        self.person = person

        super.init(hasMargin: hasMargin, headerText: headerText, footerText: footerText, pageWidth: pageWidth, pageHeight: pageHeight, hasPageNumber: hasPageNumber, pageNumber: pageNumber)
    }
    
    func drawTableData() { 
        //If draws column title = YES
        let titleFont = NSFont(name: "Helvetica Bold", size: 14.0)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSCenterTextAlignment
        
//        let titleFontAttributes = [
//            NSFontAttributeName: titleFont ?? NSFont.labelFontOfSize(12),
//            NSParagraphStyleAttributeName:titleParagraphStyle,
//            NSForegroundColorAttributeName: NSColor.grayColor()
//        ]
//        
        do {
            let fromPoint = NSMakePoint(290, self.pdfHeight - 45)
            let toPoint = NSMakePoint(self.pdfWidth, self.pdfHeight - 45)
        
            drawLine(fromPoint, toPoint: toPoint)
        }

        for yMultiplier in 1...21 {
            let height = self.pdfHeight - 45 - CGFloat(16 * yMultiplier)
            let fromPoint = NSMakePoint(92, height)
            var toPoint = NSMakePoint(self.pdfWidth, height)
            if yMultiplier == 11 {
               toPoint.x = 290
            }
            drawLine(fromPoint, toPoint: toPoint)
        }
        
        for (i, x) in [290, 322, 428, 733].enumerate() {
            let fromPointA = NSMakePoint(CGFloat(x), self.pdfHeight - 45)
            if i == 0 {
                let toPoint = NSMakePoint(CGFloat(x), self.pdfHeight - CGFloat(16 * 21 + 45))
                drawLine(fromPointA, toPoint: toPoint)
            } else {
                let toPointA = NSMakePoint(CGFloat(x), self.pdfHeight - CGFloat(16 * 6 + 45))
                drawLine(fromPointA, toPoint: toPointA)
                let fromPointB = NSMakePoint(CGFloat(x), self.pdfHeight - CGFloat(16 * 12 + 45))
                let toPointB = NSMakePoint(CGFloat(x), self.pdfHeight - CGFloat(16 * 17 + 45))
                drawLine(fromPointB, toPoint: toPointB)
            }
        }
        
        let topY = self.pdfHeight - CGFloat(16 * 21 + 45)
        drawLine(X1: 66, Y1: topY - 3, X2: self.pdfWidth, Y2: topY - 3)
        drawLine(X1: 66, Y1: topY - 3 - 16, X2: self.pdfWidth, Y2: topY - 3 - 16)
        drawLine(X1: 66, Y1: topY - 3 - 16 - 3, X2: self.pdfWidth, Y2: topY - 3 - 16 - 3)
        let newY = topY - 3 - 16 - 3
        
//        
//        for var i=0 ; i < self.columnsArray.count; i++ {
//            let columnHeader = self.columnsArray[i]
//            let columnTitle = columnHeader["columnTitle"] as! NSString
//            let headerRect = NSMakeRect(
//                leftMargin + (CGFloat(i) * defaultColumnWidth),
//                self.pdfHeight - topMargin - verticalPadding - defaultRowHeight,
//                defaultColumnWidth,
//                defaultRowHeight)
//            
//            columnTitle.drawInRect(headerRect, withAttributes: titleFontAttributes)
//            
//        }
        
        
//        for var i = 0 ; i < self.dataArray.count; i++ {
//            let dataDict = self.dataArray[i]
//            
//            for var j = 0 ; j < keys.count; j++ {
//                let dataText = dataDict[keys[j] as! String] as! NSString
//                let dataRect = NSMakeRect(
//                    leftMargin + textInset + (CGFloat(j) * defaultColumnWidth),
//                    self.pdfHeight - topMargin - verticalPadding - (2 * defaultRowHeight) - textInset - (CGFloat(i) * defaultRowHeight),
//                    defaultColumnWidth,
//                    defaultRowHeight
//                )
//                dataText.drawInRect(dataRect, withAttributes: nil)
//            }
//        }
        
    }
    
    
//    func drawHorizontalGrids(){
//        let rowCount = self.dataArray.count
//        for var i = 0 ; i <= rowCount ; i++ {
//            let fromPoint = NSMakePoint(
//                leftMargin ,
//                self.pdfHeight - topMargin - verticalPadding - defaultRowHeight - (CGFloat(i) * defaultRowHeight)
//            )
//            let toPoint = NSMakePoint(self.pdfWidth - rightMargin,
//                                      self.pdfHeight - topMargin - verticalPadding - defaultRowHeight - (CGFloat(i) * defaultRowHeight)
//            )
//            drawLine(fromPoint, toPoint: toPoint)
//        }
//        
//    }
//    
    override func drawWithBox(box: PDFDisplayBox) {
//        super.drawWithBox(box)
        self.drawTableData()
    }
    
    
}