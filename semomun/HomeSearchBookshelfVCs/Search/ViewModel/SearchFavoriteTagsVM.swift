//
//  SearchFavoriteTagsVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/25.
//

import Foundation
import Combine

final class SearchFavoriteTagsVM {
    private let networkUsecase: NetworkUsecase
    @Published private(set) var tags: [String] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecsae: NetworkUsecase) {
        self.networkUsecase = networkUsecsae
    }
    
    func fetchTags() {
        self.networkUsecase.getPopularTags { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.tags = tags
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
    
    func tag(index: Int) -> String {
        return self.tags[index]
    }
}
