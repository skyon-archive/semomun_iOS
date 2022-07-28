//
//  HomeUserTagDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/12.
//

import Foundation

final class HomeUserTagDetailVM: HomeDetailVM<WorkbookPreviewOfDB> {
    /* public */
    @Published private(set) var tags: [TagOfDB] = []
    
    override init(networkUsecase: HomeDetailVMNetworkUsecase, cellDataFetcher: @escaping CellDataFetcher) {
        super.init(networkUsecase: networkUsecase, cellDataFetcher: cellDataFetcher)
        self.configureTagObserver()
    }
    
    override func fetch() {
        self.tags = self.getFavoriteTag()
        super.fetch()
    }
}

extension HomeUserTagDetailVM {
    private func configureTagObserver() {
        NotificationCenter.default.addObserver(forName: .refreshFavoriteTags, object: nil, queue: .current) { [weak self] _ in
            self?.fetch()
        }
    }
    
    private func getFavoriteTag() -> [TagOfDB] {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            return tags
        } else {
            return []
        }
    }
}
