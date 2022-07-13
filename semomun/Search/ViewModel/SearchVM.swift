//
//  SearchVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import Foundation
import Combine

final class SearchVM {
    /* public */
    var isPaging: Bool = false
    private(set) var selectedWid: Int?
    private(set) var networkUsecase: NetworkUsecase
    @Published private(set) var favoriteTags: [TagOfDB] = []
    @Published private(set) var selectedTags: [TagOfDB] = []
    @Published private(set) var searchResultWorkbooks: [WorkbookPreviewOfDB] = []
    @Published private(set) var searchResultWorkbookGroups: [WorkbookGroupPreviewOfDB] = []
    @Published private(set) var workbookDetailInfo: WorkbookOfDB?
    @Published private(set) var warning: (title: String, text: String)?
    /* private */
    private var keyword: String = "" // 사용자 입력값
    private var pageCount: Int = 0
    private var isLastPage: Bool = false
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
}

// MARK: Public
extension SearchVM {
    func appendSelectedTag(_ tag: TagOfDB) {
        self.selectedTags.append(tag)
    }
    
    func removeSelectedTag(at index: Int) {
        guard index < self.selectedTags.count else { return }
        self.selectedTags.remove(at: index)
    }
    
    func removeAllSelectedTags() {
        self.selectedTags.removeAll()
    }
    
    func fetchWorkbookDetailInfo(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            guard let workbook = workbook else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.workbookDetailInfo = workbook
        }
    }
    
    func fetchFavoriteTags() {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.warning = ("오프라인 상태입니다", "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.")
            return
        }
        
        self.networkUsecase.getTags(order: .popularity) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.favoriteTags = Array(tags.prefix(10))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func search(keyword: String, rowCount: Int, type: SearchVC.SearchType, order: DropdownOrderButton.SearchOrder) {
        self.resetSearchInfos()
        self.keyword = keyword
        self.fetchCounts(rowCount: rowCount)
        switch type {
        case .workbook:
            self.fetchWorkbooks(rowCount: rowCount, order: order)
        case .workbookGroup:
            self.fetchWorkbookGroups(rowCount: rowCount, order: order)
        }
    }
    
    func fetchWorkbooks(rowCount: Int, order: DropdownOrderButton.SearchOrder) {
        guard self.isLastPage == false,
              self.isPaging == false else { return }
        self.isPaging = true
        self.pageCount += 1
        
        self.networkUsecase.getPreviews(tags: self.selectedTags, keyword: self.keyword, page: self.pageCount, limit: rowCount*6, order: order.param) { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                guard let workbooks = workbooks?.workbooks else {
                    self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                if workbooks.isEmpty {
                    self?.isLastPage = true
                    return
                }
                // MARK: test용 서버에서 filter 여부에 따라 searchResults 로직 분기처리
                if NetworkURL.forTest {
                    self?.filterWorkbooks(with: workbooks)
                } else {
                    self?.searchResultWorkbooks += workbooks
                }
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func fetchWorkbookGroups(rowCount: Int, order: DropdownOrderButton.SearchOrder) {
        guard self.isLastPage == false,
              self.isPaging == false else { return }
        self.isPaging = true
        self.pageCount += 1
        
        // MARK: 페이지네이션 없이 25개를 요청
        self.networkUsecase.searchWorkbookGroup(tags: self.selectedTags, keyword: self.keyword, page: self.pageCount, limit: rowCount*6, order: order.param) { [weak self] status, workbookGroups in
            switch status {
            case .SUCCESS:
                guard let workbookGroups = workbookGroups?.workbookGroups else {
                    self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                if workbookGroups.isEmpty {
                    self?.isLastPage = true
                    return
                }
                // MARK: test용 서버에서 filter 여부에 따라 searchResults 로직 분기처리
                if NetworkURL.forTest {
                    self?.filterWorkbookGroups(with: workbookGroups)
                } else {
                    self?.searchResultWorkbookGroups += workbookGroups
                }
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    /// pageCount 와 관련해 위 함수와 별개로 동일 API 를 쓰는 또다른 함수로 분리
    func fetchCounts(rowCount: Int) {
//        let taskGroup = DispatchGroup()
//        taskGroup.enter()
//        self.networkUsecase.getPreviews(tags: self.selectedTags, keyword: self.keyword, page: 1, limit: rowCount*6, order: nil) { [weak self] status, <#[WorkbookPreviewOfDB]#> in
//            <#code#>
//        }
    }
    
    func resetSearchInfos() {
        self.pageCount = 0
        self.keyword = ""
        self.searchResultWorkbooks = []
        self.searchResultWorkbookGroups = []
        self.isLastPage = false
        self.isPaging = false
    }
}

// MARK: test 서버에서 출판사 제공용일 경우 filter 후 표시
extension SearchVM {
    private func filterWorkbooks(with previews: [WorkbookPreviewOfDB]) {
        guard let testCompany = NetworkURL.testCompany else {
            self.searchResultWorkbooks += previews
            return
        }
        self.searchResultWorkbooks += previews.filter( { $0.publishCompany == testCompany })
    }
    
    private func filterWorkbookGroups(with previews: [WorkbookGroupPreviewOfDB]) {
        guard NetworkURL.testCompany != nil else {
            self.searchResultWorkbookGroups += previews
            return
        }
        self.searchResultWorkbookGroups = []
    }
}
