//
//  SearchTagsFromTextVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import Foundation
import Combine

final class SearchTagsFromTextVM {
    private let networkUsecase: NetworkUsecase
    private var totalTags: [TagOfDB] = []
    private var userSelected: [TagOfDB] = []
    @Published private(set) var filteredTags: [TagOfDB] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.configureObservation()
        self.fetchTags()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .fetchTagsFromSearch, object: nil, queue: .current) { [weak self] notification in
            guard let text = notification.userInfo?["text"] as? String else { return }
            if text == "" {
                self?.refresh()
            } else {
                self?.searchTags(text: text)
            }
        }
    }
    
    func fetchTags() {
        self.networkUsecase.getTags(order: .name) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.totalTags = tags
                self?.refresh()
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func searchTags(text: String) {
        self.filteredTags = self.totalTags.filter { $0.name.contains(text) && !self.userSelected.contains($0) }
    }
    
    func refresh() {
        self.filteredTags = self.totalTags.filter { !self.userSelected.contains($0) }
    }
    
    func updateSelectedTags(tags: [TagOfDB]) {
        self.userSelected = tags
        self.refresh()
    }
}
