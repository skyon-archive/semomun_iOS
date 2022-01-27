//
//  SearchResultVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class SearchResultVM {
    private let networkUsecase: NetworkUsecase
    private let searchResultQueue = OperationQueue()
    @Published private(set) var searchResults: [PreviewOfDB] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchSearchResults(tags: [String], text: String) {
        self.networkUsecase.getSearchResults(tags: tags, text: text) { [weak self] status, results in
            switch status {
            case .SUCCESS:
                self?.searchResults = results
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func preview(index: Int) -> PreviewOfDB {
        return self.searchResults[index]
    }
}
