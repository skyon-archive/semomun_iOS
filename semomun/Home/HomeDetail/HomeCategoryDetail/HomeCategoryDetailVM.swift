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
    typealias NetworkUsecase = (TagsFetchable&S3ImageFetchable&PreviewsSearchable&WorkbookSearchable)
    @Published private(set) var tagOfDBs: [TagOfDB] = []
    @Published private(set) var fetchedIndex: Int?
    @Published private(set) var workbookDTO: WorkbookOfDB?
    @Published private(set) var networkWarning: (String, String)?
    private(set) var sectionData: [[WorkbookPreviewOfDB]] = []
    private(set) var networkUsecase: NetworkUsecase
    var categoryName: String {
        self.categoryOfDB.name
    }
    /* private */
    private let categoryOfDB: CategoryOfDB
    
    init(categoryOfDB: CategoryOfDB, networkUsecase: NetworkUsecase) {
        self.categoryOfDB = categoryOfDB
        self.networkUsecase = networkUsecase
    }
    
    func fetch() {
        self.networkUsecase.getTags(order: .name, cid: self.categoryOfDB.cid) { [weak self] status, result in
            guard status == .SUCCESS else {
                self?.networkWarning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.tagOfDBs = result
        }
    }
    
    func fetchWorkbooks() {
        self.sectionData = Array(repeating: [], count: self.tagOfDBs.count)
        self.tagOfDBs.enumerated().forEach { index, tagOfDB in
            self.networkUsecase.getPreviews(tags: [tagOfDB], keyword: "", page: 1, limit: 15, order: nil, cid: nil) { [weak self] status, result in
                guard status == .SUCCESS else {
                    self?.networkWarning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                guard let workbooks = result?.workbooks else { return }
                self?.sectionData[index] = workbooks
                self?.fetchedIndex = index
            }
        }
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            guard let workbook = workbook else {
                self?.networkWarning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.workbookDTO = workbook
        }
    }
}
