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
class CDCovertTools {
    static func pdfToTable(_ pdfPath :String, tablePath: inout String) {
        
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
    }
    
    static func pdfToWord(_ pdfPath :String, docPath: inout String) throws {
        // Load PDF document
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
        
    }
    
    static func tableToPdf(_ tablePath: String, pdfPath: inout String) {
        //        guard let table = try? Table(csvURL: tablePath.pathUrl) else { return }
        //        let pdfDoc = PDFDocument()
        //        let pdfTable = PDFTable(table:table)
        //        pdfTable.draw(in: pdfDoc)
        //        pdfDoc.write(to: pdfPath.pathUrl)
    }
    
    static func docsToPdf(_ docPath:String, pdfPath: inout String) {
        //        guard let doc = try? Docx(fileURL: docPath.pathUrl) else { return }
        //        let pdfDoc = PDFDocument()
        //        for paragraph in doc.paragraphs {
        //            // Add paragraph text to PDF document
        //            let pdfPage = PDFPage()
        //            pdfPage.addAnnotation(PDFAnnotation(bounds:CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH),forType: .text,withProperties: nil))
        ////            pdfPage.dr
        //            pdfPage.draw(with: .text，for: CGRect(x: e, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), withAttributes:[NSAttributedstring.Key.font: UIFont.systemFont(ofSize: 12)],andOptions: nil)
        //            pdfDoc.insert(pdfPage，at: pdfDoc.pageCount)
        //        }
        //        pdfDoc.write(to: pdfPath.pathUrl)
    }
    
    static func imageToPdf(images: [UIImage], pdfPath:inout String) {
        let pdfDoc = PDFDocument()
        for image in images {
            guard let pdfPage = PDFPage(image: image) else {
                continue
            }
            pdfDoc.insert(pdfPage, at: pdfDoc.pageCount)
        }
        guard let pdfData = pdfDoc.dataRepresentation() else {
            CDHUDManager.shared.showFail("Covert to pdf fail!")
            return
        }
        let pdfURL = pdfPath.pathUrl
        do {
            try pdfData.write(to: pdfURL)
        } catch {
            CDHUDManager.shared.showFail("Covert to pdf fail!")
            CDPrintManager.log("Covert to pdf fail:\(error.localizedDescription)", type: .ErrorLog)
        }
    }
    
    static func pdfToImage(pdfPath: String, imagePath:inout String) {
        //        guard let pdfDoc = PDFDocument(url: pdfPath.pathUrl) else { return }
        //        guard let page = pdfDoc.page(at: 0) else { return }
        //        // Get image representation of PDF page
        //        let image = page.thumbnail(of: casize(width: page.bounds.width, height: page.bounds.height), for: .cropBox)
        //        try image.pngData()?.write(to: imagePath.pathUrl)
        //        CDPrintManager.log("pdf -> image success", type: .InfoLog)
    }
    
    func demo() {
        //        import Sheet
        //        import SwiftyPDF // 假设这是你用来生成PDF的库
        //
        //
    }
    
//    func excelToPDF(excelFilePath: String) -> Data? {
//        // 1. 读取Excel文件
//        let workbook = try? Workbook(url: URL(fileURLWithPath: excelFilePath))
//        guard let workbook = workbook else {
//            print("无法读取Excel文件")
//            return nil
//        }
//
//        // 假设我们只处理第一个工作表
//        let worksheet = workbook.worksheets[0]
//        let rows = worksheet.rows // 获取所有行数据
//
//        // 2. 处理数据（这里只是简单示例，实际处理可能更复杂）
//        var pdfData: Data? = nil // 用于存储PDF数据
//        let pdfDocument = PDFDocument() // 创建PDF文档对象
//        // ... 在这里填充数据到pdfDocument中 ...
//
//        // 3. 生成PDF并返回数据
//        pdfData = pdfDocument.data(withCompression: false) // 将PDF文档转换为Data对象以便保存或传输
//        return pdfData
//    }
    
//    // 使用函数将Excel文件转换为PDF并保存到本地或进行其他操作...
//    let pdfData = excelToPDF(excelFilePath: "path/to/your/excel/file.xlsx")
//    if let pdfData = pdfData {
//        // 可以将pdfData保存到本地文件或进行其他操作...
//    } else {
//        print("转换失败")
//    }
//        }
}
