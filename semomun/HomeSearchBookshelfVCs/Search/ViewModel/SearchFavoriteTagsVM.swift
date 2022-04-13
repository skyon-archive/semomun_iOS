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
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecsae: NetworkUsecase) {
        self.networkUsecase = networkUsecsae
    }
    
    func fetchTags() {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.warning = ("오프라인 상태입니다", "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.")
            return
        }
        
        self.networkUsecase.getTags(order: .popularity) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                let count = min(20, tags.count)
                self?.tags = Array(tags.prefix(upTo: count))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
}
