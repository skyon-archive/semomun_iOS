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
    @Published private(set) var tagNames: [TagOfDB] = []
    @Published private(set) var fetchedIndex: Int?
    private(set) var sectionData: [[WorkbookPreviewOfDB]] = []
    private(set) var networkUsecase: S3ImageFetchable
    /* private */
    private let cid: Int
    
    init(cid: Int, networkUsecase: S3ImageFetchable) {
        self.cid = cid
        self.networkUsecase = networkUsecase
    }
    
    func fetch() {
        
    }
}
