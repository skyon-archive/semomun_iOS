//
//  WorkbookSearchParam.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/27.
//

import Foundation

struct WorkbookSearchParam: Encodable {
    let page: Int?
    let limit: Int?
    let tids: [Int]?
    let keyword: String?
}
