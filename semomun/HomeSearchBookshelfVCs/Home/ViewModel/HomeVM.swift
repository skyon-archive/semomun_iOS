//
//  HomeVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import Foundation
import Combine

final class HomeVM {
    private(set) var networkUsecase: NetworkUsecase
    @Published private(set) var ads: [(String, String)] = [] // DTO로 타입이 변경될 부분
    @Published private(set) var bestSellers: [PreviewOfDB] = []
    @Published private(set) var workbooksWithTags: [PreviewOfDB] = []
    @Published private(set) var workbooksWithRecent: [BookshelfInfo] = []
    @Published private(set) var workbooksWithNewest: [BookshelfInfo] = []
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var workbookDTO: WorkbookOfDB?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.configureObservation()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .refreshFavoriteTags, object: nil, queue: .main) { [weak self] _ in
            self?.fetchTags()
        }
    }
    
    func fetchAll() {
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        
        self.fetchSome()
        self.fetchWorkbooksWithRecent()
        self.fetchWorkbooksWithNewest()
    }
    
    func fetchSome() {
        self.fetchTags()
        self.fetchAds()
        self.fetchBestSellers()
    }
    
    private func fetchTags() {
        if let tagsData = UserDefaultsManager.get(forKey: .favoriteTags) as? Data,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.tags = tags
        } else {
            self.tags = []
        }
        
        self.fetchWorkbooksWithTags()
    }
    
    private func fetchAds() {
        self.ads = (1...5).map { ("banner\($0)", "https://forms.gle/suXByYKEied6RcSd8")}
    }
    
    private func fetchBestSellers() {
        self.networkUsecase.getBestSellers { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                let count = min(10, workbooks.count)
                self?.bestSellers = Array(workbooks.prefix(upTo: count))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
    
    private func fetchWorkbooksWithTags() {
        self.networkUsecase.getPreviews(tags: self.tags, text: "", page: 1, limit: 10) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                let count = min(10, previews.count)
                self?.workbooksWithTags = Array(previews.prefix(upTo: count))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
    
    private func fetchWorkbooksWithRecent() {
        self.networkUsecase.getUserBookshelfInfos(order: .solve) { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                let infos = infos.map { BookshelfInfo(info: $0) }.filter { $0.recentDate != nil }
                let count = min(10, infos.count)
                self?.workbooksWithRecent = Array(infos.prefix(upTo: count))
            default:
                self?.warning = (title: "구매내역 수신 에러", text: "네트워크 확인 후 재시도해주시기 바랍니다.")
            }
        }
    }
    
    private func fetchWorkbooksWithNewest() {
        self.networkUsecase.getUserBookshelfInfos(order: .purchase) { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                let infos = infos.map { BookshelfInfo(info: $0) }
                let count = min(10, infos.count)
                self?.workbooksWithNewest = Array(infos.prefix(upTo: count))
            default:
                self?.warning = (title: "구매내역 수신 에러", text: "네트워크 확인 후 재시도해주시기 바랍니다.")
            }
        }
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            self?.workbookDTO = workbook
        }
    }
}
