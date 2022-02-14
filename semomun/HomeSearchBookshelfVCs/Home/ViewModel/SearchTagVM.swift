//
//  SearchTagVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import Foundation
import Combine

final class SearchTagVM {
    private let networkUsecase: NetworkUsecase
    @Published private(set) var tags: [String] = []
    @Published private(set) var searchResultTags: [String] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.fetchTags()
    }
    
    private func fetchTags() {
        let tags = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.favoriteTags) as? [String] ?? ["수능"]
        self.tags = tags
    }
    
    func searchTags(text: String) {
        self.networkUsecase.getTagsFromSearch(text: text) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.searchResultTags = tags
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func removeTag(index: Int) {
        self.tags.remove(at: index)
    }
    
    func removeAll() {
        self.searchResultTags = []
    }
}
