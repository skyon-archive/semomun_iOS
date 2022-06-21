//
//  WorkbookInfo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation

struct WorkbookInfo {
    let title: String
    let author: String
    let publisher: String
    var releaseDate: String
    let fileSize: String
    let isbn: String
    let price: Int
    let imageData: Data?
    let bookcover: UUID?
    
    init(previewCore: Preview_Core) {
        self.title = previewCore.title ?? "문제집 제목 없음"
        self.author = previewCore.author != "" ? (previewCore.author ?? "저자 정보 없음") : "저자 정보 없음"
        self.publisher = previewCore.publisher != "" ? (previewCore.publisher ?? "출판사 정보 없음") : "출판사 정보 없음"
        self.releaseDate = previewCore.publishedDate?.koreanYearMonthDayText ?? "출판일 정보 없음"
        if let yearIndex = releaseDate.firstIndex(of: "년") {
            self.releaseDate.insert("\n", at: releaseDate.index(after: yearIndex))
        }
        let byteSize = Int(previewCore.fileSize)
        self.fileSize = byteSize.byteToMBString
        self.isbn = previewCore.isbn ?? ""
        self.price = Int(previewCore.price)
        self.imageData = previewCore.image
        self.bookcover = nil
    }
    
    init(workbookDTO: WorkbookOfDB) {
        let sectionInfos = workbookDTO.sections
        self.title = workbookDTO.title
        self.author = workbookDTO.author != "" ? workbookDTO.author : "저자 정보 없음"
        self.publisher = workbookDTO.publishCompany != "" ? workbookDTO.publishCompany : "출판사 정보 없음"
        self.releaseDate = workbookDTO.publishedDate.koreanYearMonthDayText
        if let yearIndex = releaseDate.firstIndex(of: "년") {
            self.releaseDate.insert("\n", at: releaseDate.index(after: yearIndex))
        }
        let byteSize = sectionInfos.reduce(0, { $0 + $1.fileSize })
        self.fileSize = byteSize.byteToMBString
        self.isbn = workbookDTO.isbn
        self.price = workbookDTO.price
        self.imageData = nil
        self.bookcover = workbookDTO.bookcover
    }
}
