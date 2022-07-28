//
//  HomeCategoryDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import Foundation
import Combine

final class HomeCategoryDetailVM {
    /* public */
    @Published private(set) var sectionData: [[WorkbookPreviewOfDB]] = []
    @Published private(set) var fetchedIndex: Int?
    /* private */
    private let cid: Int
    
    init(cid: Int) {
        self.cid = cid
    }
    
    func fetch() {
        
    }
}
