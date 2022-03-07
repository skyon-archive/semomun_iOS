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
    @Published private(set) var workbooksWithRecent: [PreviewOfDB] = []
    @Published private(set) var workbooksWithNewest: [PreviewOfDB] = []
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: (String, String)?
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
        self.networkUsecase.getSearchPreviews(tags: self.tags, text: "", page: 1, limit: 10) { [weak self] status, previews in
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
        self.networkUsecase.getWorkbooksWithRecent { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                let count = min(10, workbooks.count)
                self?.workbooksWithRecent = Array(workbooks.prefix(upTo: count))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.error = "네트워크 연결을 확인 후 다시 시도하세요"
            }
        }
    }
    
    private func fetchWorkbooksWithNewest() {
        self.networkUsecase.getWorkbooksWithNewest { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                let count = min(10, workbooks.count)
                self?.workbooksWithNewest = Array(workbooks.prefix(upTo: count))
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
    
    func workbookWithTags(index: Int) -> PreviewOfDB {
        return self.workbooksWithTags[index]
    }
    
    func workbookWithRecent(index: Int) -> PreviewOfDB {
        return self.workbooksWithRecent[index]
    }
    
    func workbookWithNewest(index: Int) -> PreviewOfDB {
        return self.workbooksWithNewest[index]
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.downloadWorkbook(wid: wid) { [weak self] workbook in
            self?.workbookDTO = workbook
        }
    }
}
