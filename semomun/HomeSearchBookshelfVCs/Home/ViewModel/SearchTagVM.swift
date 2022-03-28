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
    private var totalTags: [TagOfDB] = []
    @Published private(set) var filteredTags: [TagOfDB] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var userTags: [TagOfDB] = []
    
    init(networkUsecase: TagsFetchable) {
        self.networkUsecase = networkUsecase
        self.fetchTagsFromLocal()
        self.fetchTagsFromServer()
    }
    
    private func fetchTagsFromLocal() {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.userTags = tags
        } else {
            self.userTags = []
        }
    }
    
    private func fetchTagsFromServer() {
        self.networkUsecase.getTags(order: .name) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.totalTags = tags
                self?.filteredTags = tags
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func searchTags(text: String) {
        if text == "" {
            self.filteredTags = self.totalTags
        } else {
            self.filteredTags = self.totalTags.filter { $0.name.contains(text) }
        }
    }
    
    func removeTag(index: Int) {
        self.userTags.remove(at: index)
        self.saveTags()
    }
    
    func appendTag(_ newElement: TagOfDB) {
        guard self.userTags.count < 5 else {
            self.warning = ("5개 이하만 선택해주세요", "")
            return
        }
        self.userTags.append(newElement)
        self.filteredTags = []
        self.saveTags()
    }
    
    private func saveTags() {
        let data = try? PropertyListEncoder().encode(self.userTags)
        UserDefaultsManager.favoriteTags = data
        NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
    }
}
