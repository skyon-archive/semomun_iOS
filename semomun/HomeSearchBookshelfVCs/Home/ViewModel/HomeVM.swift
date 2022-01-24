//
//  HomeVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import Foundation
import Combine

final class HomeVM {
    private let networkUsecase: NetworkUsecase
    @Published private(set) var tags: [String] = []
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchTags() {
        guard let tags = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.favoriteTags) as? [String] else { return }
        self.tags = tags
    }
}
