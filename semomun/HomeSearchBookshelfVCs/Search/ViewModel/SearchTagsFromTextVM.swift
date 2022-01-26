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
    private let searchQueue = OperationQueue()
    @Published private(set) var tags: [String] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.configureObservation()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .fetchTagsFromSearch, object: nil, queue: self.searchQueue) { [weak self] notification in
            print("search")
            guard let text = notification.userInfo?["text"] as? String else { return }
            
            self?.fetchTags(text: text)
        }
    }
    
    private func fetchTags(text: String) {
        self.networkUsecase.getTagsFromSearch(text: text) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.tags = tags
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func tag(index: Int) -> String {
        return self.tags[index]
    }
    
    func removeAll() {
        self.tags.removeAll()
    }
}
