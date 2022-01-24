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
    @Published private(set) var ads: [String] = [] // DTO로 타입이 변경될 부분
    @Published private(set) var bestSellers: [PreviewOfDB] = []
    @Published private(set) var workbooksWithTags: [PreviewOfDB] = []
    @Published private(set) var workbooksWithRecent: [PreviewOfDB] = []
    @Published private(set) var workbooksWithNewest: [PreviewOfDB] = []
    @Published private(set) var tags: [String] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchTags() {
        guard let tags = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.favoriteTags) as? [String] else { return }
        self.tags = tags
    }
    
    func fetchAds() {
        self.ads = Array(repeating: "https://forms.gle/suXByYKEied6RcSd8", count: 5)
    }
    
    func fetchBestSellers() {
        self.networkUsecase.getBestSellers { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                print(Array(workbooks.prefix(upTo: 10)))
                self?.bestSellers = Array(workbooks.prefix(upTo: 10))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
    
    func bestSeller(index: Int) -> PreviewOfDB {
        return self.bestSellers[index]
    }
    
    func testAd(index: Int) -> String {
        return self.ads[index]
    }
}
