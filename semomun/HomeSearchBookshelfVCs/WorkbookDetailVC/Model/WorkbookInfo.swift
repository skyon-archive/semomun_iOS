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
    
    init(previewCore: Preview_Core) {
        self.title = previewCore.title ?? "문제집 제목 없음"
        self.author = "저자 정보 없음"
        self.publisher = previewCore.publisher ?? "출판사 정보 없음"
        self.releaseDate = ""
        self.fileSize = "30.8MB"
        self.isbn = "987-6543210987"
        self.price = Int(previewCore.price)
        self.imageData = previewCore.image
        self.configureReleaseDate(previewCore: previewCore)
    }
    
    init(workbookDTO: SearchWorkbook) {
        let workbookInfo = workbookDTO.workbook
        let sectionInfos = workbookDTO.sections
        self.title = workbookInfo.title
        self.author = workbookInfo.author
        self.publisher = workbookInfo.publishCompany
        self.releaseDate = ""
        self.fileSize = "\(sectionInfos.reduce(0, { $0 + $1.size }))MB"
        self.isbn = workbookInfo.isbn
        self.price = Int(workbookInfo.originalPrice) ?? 0 //TODO: 정가 -> 판매가 수정 필요
        self.imageData = nil
        self.configureReleaseDate(workbookDTO: workbookInfo)
    }
    
    private mutating func configureReleaseDate(previewCore: Preview_Core) {
        self.releaseDate = "CoreData: data 반영 예정"
    }
    
    private mutating func configureReleaseDate(workbookDTO: WorkbookOfDB) {
        self.releaseDate = "\(workbookDTO.date)"
    }
}
