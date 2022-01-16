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
    let image: Data?
    let imageURL: String?
    
    init(previewCore: Preview_Core) {
        self.title = previewCore.title ?? "문제집 제목 없음"
        self.author = "저자 정보 없음"
        self.publisher = previewCore.publisher ?? "출판사 정보 없음"
        self.image = previewCore.image
        self.imageURL = nil
        self.releaseDate = ""
        self.configureReleaseDate(previewCore: previewCore)
    }
    
    init(workbookDTO: WorkbookOfDB) {
        self.title = workbookDTO.title
        self.author = "저자 정보 없음"
        self.publisher = workbookDTO.publisher
        self.image = nil
        self.imageURL = workbookDTO.bookcover
        self.releaseDate = ""
        self.configureReleaseData(workbookDTO: workbookDTO)
    }
    
    private mutating func configureReleaseDate(previewCore: Preview_Core) {
        if let year = previewCore.year {
            if let month = previewCore.month {
                self.releaseDate = "\(year)년 \(month)월"
            } else {
                self.releaseDate = "\(year)년"
            }
        } else {
            self.releaseDate = ""
        }
    }
    
    private mutating func configureReleaseData(workbookDTO: WorkbookOfDB) {
        self.releaseDate = "\(workbookDTO.year)년 \(workbookDTO.month)월"
    }
}
