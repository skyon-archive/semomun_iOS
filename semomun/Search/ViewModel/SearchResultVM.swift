//
//  SearchResultVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class SearchResultVM {
    /* public */
    var isWorkbookPaging: Bool = false
    var isWorkbookGroupPaging: Bool = false
    /* private */
    private(set) var networkUsecase: NetworkUsecase
    private var tags: [TagOfDB] = []
    private var text: String = ""
    // MARK: Pagination 관려
    private var workbookPageCount: Int = 0
    private var workbookGroupPageCount: Int = 0
    private var isWorkbookLastPage: Bool = false
    private var isWorkbookGroupLastPage: Bool = false
    @Published private(set) var workbookSearchResults: [WorkbookPreviewOfDB] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchSearchResults(tags: [TagOfDB], text: String, rowCount: Int) {
        self.tags = tags
        self.text = text
        self.fetchWorkbookSearchResults(rowCount: rowCount)
    }
    
    func fetchWorkbookSearchResults(rowCount: Int) {
        guard self.isWorkbookLastPage == false,
              self.isWorkbookPaging == false else { return }
        self.isWorkbookPaging = true
        self.workbookPageCount += 1
        
        self.networkUsecase.getPreviews(tags: self.tags, keyword: self.text, page: self.workbookPageCount, limit: rowCount*10, order: nil, cid: nil) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                guard let previews = previews?.workbooks else {
                    self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                if previews.isEmpty {
                    self?.isWorkbookLastPage = true
                    return
                }
                    self?.workbookSearchResults += previews
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func removeAll() {
        self.workbookPageCount = 0
        self.workbookSearchResults = []
        self.isWorkbookLastPage = false
        self.isWorkbookPaging = false
    }
}
