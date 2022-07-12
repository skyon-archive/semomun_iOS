//
//  HomeTagDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/12.
//

import Foundation

final class HomeTagDetailVM: HomeDetailVM<WorkbookPreviewOfDB> {
    /* public */
    @Published private(set) var tags: [String] = []
    
    override init(networkUsecase: HomeDetailVMNetworkUsecase, cellDataFetcher: @escaping CellDataFetcher) {
        super.init(networkUsecase: networkUsecase, cellDataFetcher: cellDataFetcher)
        self.configureTagObserver()
    }
    
    override func fetch() {
        self.tags = self.getFavoriteTag().map(\.name)
        super.fetch()
    }
}

extension HomeTagDetailVM {
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
