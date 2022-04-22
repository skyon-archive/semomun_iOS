//
//  SearchTagVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import Foundation
import Combine

typealias SearchTagNetworkUsecase = TagsFetchable & UserInfoSendable

final class SearchTagVM {
    private let networkUsecase: SearchTagNetworkUsecase
    private var totalTags: [TagOfDB] = []
    @Published private(set) var filteredTags: [TagOfDB] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var userTags: [TagOfDB] = [] {
        didSet { self.setFilteredTags() }
    }
    private var searchedText: String = "" {
        didSet { self.setFilteredTags() }
    }
    
    init(networkUsecase: SearchTagNetworkUsecase) {
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
    
    private func setFilteredTags() {
        self.filteredTags = self.totalTags.filter {
            (self.searchedText == "" || $0.name.contains(self.searchedText)) && !self.userTags.contains($0)
        }
    }
    
    private func fetchTagsFromServer() {
        self.networkUsecase.getTags(order: .name) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.totalTags = tags
                self?.setFilteredTags()
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func searchTags(text: String) {
        self.searchedText = text
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
        self.saveTags()
    }
    
    private func saveTags() {
        guard UserDefaultsManager.isLogined else {
            self.saveUserDefaultsFavoriteTags()
            return
        }
        
        self.networkUsecase.putUserSelectedTags(tags: self.userTags) { [weak self] status in
            guard status == .SUCCESS else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            
            self?.saveUserDefaultsFavoriteTags()
        }
    }
    
    private func saveUserDefaultsFavoriteTags() {
        let data = try? PropertyListEncoder().encode(self.userTags)
        UserDefaultsManager.favoriteTags = data
        NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
    }
}
