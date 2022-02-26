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
    let image: Data?
    let imageURL: String?
    
    init(previewCore: Preview_Core) {
        self.title = previewCore.title ?? "문제집 제목 없음"
        self.author = "저자 정보 없음"
        self.publisher = previewCore.publisher ?? "출판사 정보 없음"
        self.releaseDate = ""
        self.fileSize = "30.8MB"
        self.isbn = "987-6543210987"
        self.price = Int(previewCore.price)
        self.image = previewCore.image
        self.imageURL = nil
        self.configureReleaseDate(previewCore: previewCore)
    }
    
    init(workbookDTO: WorkbookOfDB) {
        self.title = workbookDTO.title
        self.author = "저자 정보 없음"
        self.publisher = workbookDTO.publishCompany
        self.releaseDate = ""
        self.fileSize = "30.8MB"
        self.isbn = "987-6543210987"
        self.price = Int(workbookDTO.originalPrice) ?? 0
        self.image = nil
        self.imageURL = workbookDTO.bookcover
        self.configureReleaseDate(workbookDTO: workbookDTO)
    }
    
    private mutating func configureReleaseDate(previewCore: Preview_Core) {
        self.releaseDate = "CoreData: data 반영 예정"
    }
    
    private mutating func configureReleaseDate(workbookDTO: WorkbookOfDB) {
        self.releaseDate = "\(workbookDTO.date)"
    }
}
