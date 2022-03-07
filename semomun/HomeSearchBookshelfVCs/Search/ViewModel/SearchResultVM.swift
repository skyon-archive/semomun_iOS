//
//  SearchResultVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class SearchResultVM {
    private let searchResultQueue = OperationQueue()
    private(set) var networkUsecase: NetworkUsecase
    private var pageCount: Int = 0
    private var tags: [TagOfDB] = []
    private var text: String = ""
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
        self.pageCount += 1
        self.networkUsecase.getSearchPreviews(tags: self.tags, text: self.text, page: self.pageCount, limit: 20) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
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
    }
}
