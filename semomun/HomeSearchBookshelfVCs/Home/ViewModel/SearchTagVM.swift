//
//  SearchTagVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import Foundation
import Combine

final class SearchTagVM {
    private let networkUsecase: TagsFetchable
    @Published private(set) var searchResultTags: [TagOfDB] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var tags: [TagOfDB] = []
    
    init(networkUsecase: TagsFetchable) {
        self.networkUsecase = networkUsecase
        self.fetchTags()
    }
    
    private func fetchTags() {
        if let tagsData = UserDefaultsManager.get(forKey: .favoriteTags) as? Data,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.tags = tags
        } else {
            self.tags = []
        }
    }
    
    func searchTags(text: String) {
        self.networkUsecase.getTags(order: .name) { [weak self] status, tags in
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
        self.saveTags()
    }
    
    func appendTag(to tag: TagOfDB) {
        guard self.tags.count < 5 else {
            self.warning = ("5개 이하만 선택해주세요", "")
            return
        }
        self.tags.append(tag)
        self.removeAll()
        self.saveTags()
    }
    
    func removeAll() {
        self.searchResultTags = []
    }
    
    private func saveTags() {
        let data = try? PropertyListEncoder().encode(self.tags)
        UserDefaultsManager.set(to: data, forKey: .favoriteTags)
        NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
    }
}
