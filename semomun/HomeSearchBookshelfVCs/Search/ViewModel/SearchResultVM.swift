//
//  SearchResultVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class SearchResultVM {
    var isPaging: Bool = false
    private let searchResultQueue = OperationQueue()
    private(set) var networkUsecase: NetworkUsecase
    private var pageCount: Int = 0
    private var tags: [TagOfDB] = []
    private var text: String = ""
    private var isLastPage: Bool = false
    @Published private(set) var searchResults: [PreviewOfDB] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchSearchResults(tags: [TagOfDB], text: String) {
        self.tags = tags
        self.text = text
        self.fetchSearchResults()
    }
    
    func fetchSearchResults() {
        guard self.isLastPage == false,
              self.isPaging == false else { return }
        self.isPaging = true
        self.pageCount += 1
        // limit : 12인치의 6배수, 11인치의 5배수, 미니의 4배수의 LCM : 60
        self.networkUsecase.getPreviews(tags: self.tags, text: self.text, page: self.pageCount, limit: 60) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                if previews.isEmpty {
                    self?.isLastPage = true
                    return
                }
                self?.searchResults += previews
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func removeAll() {
        self.pageCount = 0
        self.searchResults = []
        self.isLastPage = false
        self.isPaging = false
    }
}
