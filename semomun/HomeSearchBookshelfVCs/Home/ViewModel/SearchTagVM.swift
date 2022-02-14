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
    
    func removeTag(index: Int) {
        self.tags.remove(at: index)
    }
}
