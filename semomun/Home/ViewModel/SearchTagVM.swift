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
    /* public */
    @Published private(set) var searchResult: [TagOfDB] = []
    @Published private(set) var userTags: [TagOfDB] = [] {
        didSet { self.updateSearchResult() }
    }
    @Published private(set) var warning: (title: String, text: String)?
    /* private */
    private let networkUsecase: SearchTagNetworkUsecase
    private var totalTags: [TagOfDB] = []
    private var keyword = ""
    
    init(networkUsecase: SearchTagNetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetch() {
        self.fetchFromLocal()
        self.fetchFromServer()
    }
    
    func search(keyword: String) {
        self.keyword = keyword
        self.updateSearchResult()
    }
    
    func addUserTag(_ newElement: TagOfDB) {
        guard self.userTags.count <= 10 else { return }
        self.userTags.append(newElement)
    }
    
    func removeUserTag(index: Int) {
        self.userTags.remove(at: index)
    }
    
    func save() {
        guard UserDefaultsManager.isLogined else {
            self.saveToLocal()
            return
        }
        self.saveToServer { [weak self] in
            self?.saveToLocal()
        }
    }
}

extension SearchTagVM {
    private func updateSearchResult() {
        self.searchResult = self.totalTags.filter {
            (self.keyword == "" || $0.name.contains(self.keyword)) && !self.userTags.contains($0)
        }
    }
    
    private func fetchFromLocal() {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.userTags = tags
        } else {
            self.userTags = []
        }
    }
    
    private func fetchFromServer() {
        self.networkUsecase.getTags(order: .name) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.totalTags = tags
                self?.updateSearchResult()
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func saveToLocal() {
        let data = try? PropertyListEncoder().encode(self.userTags)
        UserDefaultsManager.favoriteTags = data
        NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
    }
    
    private func saveToServer(completion: @escaping () -> Void) {
        self.networkUsecase.putUserSelectedTags(tags: self.userTags) { [weak self] status in
            guard status == .SUCCESS else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            completion()
        }
    }
}
