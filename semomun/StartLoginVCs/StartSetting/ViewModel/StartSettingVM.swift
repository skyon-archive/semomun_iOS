//
//  StartSettingVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/23.
//

import Foundation
import Combine

final class StartSettingVM {
    private let networkUsecase: NetworkUsecase
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: String?
    @Published private(set) var selectedTags: [TagOfDB] = []
    private(set) var selectedIndexes: [Int] = []
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchTags() {
        self.networkUsecase.getTags(order: .popularity) { [weak self] status, tags in
            self?.tags = tags
        }
    }
    
    func select(to index: Int) {
        // 제거
        if self.selectedIndexes.contains(index) {
            self.selectedIndexes.removeAll(where: { $0 == index })
            self.selectedTags.removeAll(where: { $0.tid == self.tags[index].tid })
        }
        // 추가
        else {
            if selectedTags.count >= 5 {
                self.warning = "5개 이하만 선택해주세요"
                return
            }
            self.selectedIndexes.append(index)
            self.selectedTags.append(self.tags[index])
        }
    }
    
    func saveUserDefaults() {
        let data = try? PropertyListEncoder().encode(self.selectedTags)
        UserDefaultsManager.favoriteTags = data
        UserDefaultsManager.isInitial = false
    }
    
    var isSelectFinished: Bool {
        return self.selectedTags.count > 0 && self.selectedTags.count <= 5
    }
}
