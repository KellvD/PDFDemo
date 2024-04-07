//
//  Tools.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import Foundation
import PDFKit
//import Tabular
//import Docx
//class Tools {
//    func pdfToTable(_ pdfPath :String, tablePath: inout String) throws {
//        
//        guard let pdfDoc = PDFDocument(url: pdfPath.pathUrl) else { return }
//        // Create table
//        let table = Table()
//        for i in 0..<pdfDoc.pageCount{
//            guard let page = pdfDoc.page(at:i) else { continue}
//            let text = page.string ?? ""
//            let rows = text.components(separatedBy:"\n")
//            let columns = rows.map { $0.components(separatedBy:"")}
//            // Add rows and columns to table
//            for row in columns {
//                let tableRow = TableRow()
//                for column in row {
//                    let tableCell = TableCell(text:column)
//                    tableRow.addCell(tableCell)
//                    
//                }
//                table.addRow(tableRow)
//            }
//        }
//        try table.saveAsCSV(to: csvURL)
//    }
//    
//    func pdfToWord(_ pdfPath :String, docPath: inout String) throws {
//        // Load PDF document
//        guard let pdfDoc = PDFDocument(url: pdfPath.pathUrl)else { return }
//        // Create Word document
//        let doc = Docx()
//        // Loop through PDF pages
//        for i in 0..<pdfDoc.pageCount {
//            guard let page = pdfDoc.page(at: i) else { continue }
//            // Convert PDF page to image
//            let image = page.thumbnail(of: CGsize(width:page.bounds.width, height:page.bounds.height),for:.cropBox)
//            // Add image to Word document
//            let paragraph = doc.addParagraph()
//            paragraph.addImage(image)
//        }
//        try doc.save(to: docPath.pathUrl)
//
//    }
//    
//    func tableToPdf(_ tablePath: String, pdfPath: inout String) {
//        guard let table = try? Table(csvURL: tablePath.pathUrl) else { return }
//        let pdfDoc = PDFDocument()
//        let pdfTable = PDFTable(table:table)
//        pdfTable.draw(in: pdfDoc)
//        pdfDoc.write(to: pdfPath.pathUrl)
//    }
//    
//    func docsToPdf(_ docPath:String, pdfPath: inout String) {
////        guard let doc = try? Docx(fileURL: docPath.pathUrl) else { return }
////        let pdfDoc = PDFDocument()
////        for paragraph in doc.paragraphs {
////            // Add paragraph text to PDF document
////            let pdfPage = PDFPage()
////            pdfPage.addAnnotation(PDFAnnotation(bounds:CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH),forType: .text,withProperties: nil))
//////            pdfPage.dr
////            pdfPage.draw(with: .text，for: CGRect(x: e, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), withAttributes:[NSAttributedstring.Key.font: UIFont.systemFont(ofSize: 12)],andOptions: nil)
////            pdfDoc.insert(pdfPage，at: pdfDoc.pageCount)
////        }
////        pdfDoc.write(to: pdfPath.pathUrl)
//    }
//    
//    func imageToPdf(image: UIImage, pdfPath:inout String) {
//        let pdfData = NSMutableData()
//        let pdfBounds = CGRect(x: 0,y: 0, width: image.size.width, height: image.size.height)
//        UIGraphicsBeginPDFContextToData(pdfData，pdfBounds,nil)
//        // Add image to PDF context
//        UIGraphicsBeginPDFPage()
//        image.draw(in: pdfBounds)
//        UIGraphicsEndPDFContext()
//        let pdfURL = String.RootPath.appendingPathComponent(str: "example.pdf").pathUrl
//        pdfData.write(to:pdfURL,atomically:true)
//    }
//    
//    func pdfToImage(pdfPath: String, imagePath:inout String) {
//        guard let pdfDoc = PDFDocument(url: pdfPath.pathUrl) else { return }
//        guard let page = pdfDoc.page(at: 0) else { return }
//        // Get image representation of PDF page
//        let image = page.thumbnail(of: casize(width: page.bounds.width, height: page.bounds.height), for: .cropBox)
//        try image.pngData()?.write(to: imagePath.pathUrl)
//        CDPrintManager.log("pdf -> image success", type: .InfoLog)
//    }
//}
