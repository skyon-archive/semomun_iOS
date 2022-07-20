//
//  HomeBookcoverCellInfo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import Foundation

protocol HomeBookcoverCellInfo {
    var title: String { get }
    var publishCompany: String { get }
    var bookcover: UUID { get }
    
    var workbookDetailInfo: (wid: Int?, workbookGroupPreviewOfDB: WorkbookGroupPreviewOfDB?) { get }
}
