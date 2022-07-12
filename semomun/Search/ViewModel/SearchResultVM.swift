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
    @Published private(set) var workbookGroupSearchResults: [WorkbookGroupPreviewOfDB] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchSearchResults(tags: [TagOfDB], text: String, rowCount: Int) {
        self.tags = tags
        self.text = text
        self.fetchWorkbookSearchResults(rowCount: rowCount)
        self.fetchWorkbookGroupSearchResults(rowCount: rowCount)
    }
    
    func fetchWorkbookSearchResults(rowCount: Int) {
        guard self.isWorkbookLastPage == false,
              self.isWorkbookPaging == false else { return }
        self.isWorkbookPaging = true
        self.workbookPageCount += 1
        
        self.networkUsecase.getPreviews(tags: self.tags, keyword: self.text, page: self.workbookPageCount, limit: rowCount*10, order: nil) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                if previews.isEmpty {
                    self?.isWorkbookLastPage = true
                    return
                }
                // MARK: test용 서버에서 filter 여부에 따라 searchResults 로직 분기처리
                if NetworkURL.forTest {
                    self?.filterWorkbookSearchResults(with: previews)
                } else {
                    self?.workbookSearchResults += previews
                }
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    // MARK: 모의고사는 페이지네이션이 없기에 현재 VM 내부에서만 사용. 한번 요청에 모든 모의고사를 받아올 수 있음이 전제.
    private func fetchWorkbookGroupSearchResults(rowCount: Int) {
        guard self.isWorkbookGroupLastPage == false,
              self.isWorkbookGroupPaging == false else { return }
        self.isWorkbookGroupPaging = true
        self.workbookGroupPageCount += 1
        
        // MARK: 페이지네이션 없이 25개를 요청
        self.networkUsecase.searchWorkbookGroup(tags: self.tags, keyword: self.text, page: self.workbookGroupPageCount, limit: 25, order: nil) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                if previews.isEmpty {
                    self?.isWorkbookGroupLastPage = true
                    return
                }
                // MARK: test용 서버에서 filter 여부에 따라 searchResults 로직 분기처리
                if NetworkURL.forTest {
                    self?.filterWorkbookGroupSearchResults(with: previews)
                } else {
                    self?.workbookGroupSearchResults += previews
                }
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

// MARK: test 서버에서 출판사 제공용일 경우 filter 후 표시
extension SearchResultVM {
    private func filterWorkbookSearchResults(with previews: [WorkbookPreviewOfDB]) {
        guard let testCompany = NetworkURL.testCompany else {
            self.workbookSearchResults += previews
            return
        }
        self.workbookSearchResults += previews.filter( { $0.publishCompany == testCompany })
    }
    
    private func filterWorkbookGroupSearchResults(with previews: [WorkbookGroupPreviewOfDB]) {
        guard NetworkURL.testCompany != nil else {
            self.workbookGroupSearchResults += previews
            return
        }
        self.workbookGroupSearchResults = []
    }
}
