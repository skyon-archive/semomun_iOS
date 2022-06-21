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
    @Published private(set) var banners: [Banner] = []
    @Published private(set) var bestSellers: [PreviewOfDB] = []
    @Published private(set) var workbooksWithTags: [PreviewOfDB] = [] // MARR: 추후 각 tag 별로 section 이 분리되어 표시할 예정
    @Published private(set) var workbookGroups: [WorkbookGroupOfDB] = [] // 2.1: 실전 모의고사
    @Published private(set) var recentEntered: [BookshelfInfo] = []
    @Published private(set) var recentPurchased: [BookshelfInfo] = []
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var workbookDTO: WorkbookOfDB?
    @Published private(set) var offlineStatus: Bool = false
    @Published private(set) var logined: Bool = false
    @Published private(set) var updateToVersion: String?
    @Published private(set) var popupURL: URL?
    @Published private(set) var isMigration: Bool = false
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.configureObservation()
        NetworkStatusManager.state()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .refreshFavoriteTags, object: nil, queue: .current) { [weak self] _ in
            self?.fetchTags()
        }
        // MARK: - NetworkStatusManager.state() 메소드를 실행함에 따라 온라인일 경우 항상 한번 이상 실행된다.
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.connected, object: nil, queue: .current) { [weak self] _ in
            self?.fetch()
        }
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.disconnected, object: nil, queue: .current) { [weak self] _ in
            self?.offlineStatus = true // 온라인 -> 오프라인으로 변화시 동작
        }
        NotificationCenter.default.addObserver(forName: .checkHomeNetworkFetchable, object: nil, queue: .current) { [weak self] _ in
            self?.fetch()
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .current) { [weak self] _ in
            self?.logined = true
            self?.fetchLogined()
        }
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .current) { [weak self] _ in
            self?.fetchLogined()
        }
        NotificationCenter.default.addObserver(forName: .refreshBookshelf, object: nil, queue: .current) { [weak self] _ in
            self?.fetchLogined()
        }
    }
    
    func checkLogined() { // VC 에서 불리는 함수
        self.logined = UserDefaultsManager.isLogined
    }
    
    func checkVersion() { // VC 에서 불리는 함수
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        self.networkUsecase.getAppstoreVersion { [weak self] status, appstoreVersion in
            switch status {
            case .SUCCESS:
                guard let deviceVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                let appstoreVersion = appstoreVersion else {
                    assertionFailure()
                    return
                }

                if deviceVersion.versionCompare(appstoreVersion) == .orderedAscending {
                    self?.updateToVersion = appstoreVersion
                }
            case .FAIL:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            default:
                return
            }
        }
    }
    
    func checkMigration() {
        let coreVersion = UserDefaultsManager.coreVersion
        if self.logined && coreVersion.compare(String.latestCoreVersion, options: .numeric) == .orderedAscending {
            print("HOMEVM : migration start")
            self.isMigration = true
            self.migration()
        }
    }
    
    private func migration() {
        CoreUsecase.migration { [weak self] migrationSuccess in
            guard migrationSuccess else {
                self?.isMigration = false
                self?.warning = ("동기화 실패", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            
            print("HOMEVM : migration success")
            self?.isMigration = false
            self?.fetchLogined()
        }
    }
    
    private func fetch() {
        self.offlineStatus = NetworkStatusManager.isConnectedToInternet() == false
        self.fetchNonLogined()
        
        if self.logined {
            SyncUsecase(networkUsecase: self.networkUsecase).syncUserDataFromDB { [weak self] status in
                switch status {
                case .success(_):
                    print("Home: 유저 정보 동기화 성공")
                    self?.fetchLogined()
                default:
                    self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
            }
        }
    }
    
    private func fetchNonLogined() {
        self.fetchAds()
        self.fetchBestSellers()
        self.fetchTags()
        self.fetchPracticeTests()
        self.fetchPopup()
    }
    
    private func fetchLogined() {
        self.fetchRecentEnters()
        self.fetchPurchased()
    }
    
    private func fetchTags() {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.tags = tags
        } else {
            self.tags = []
        }
        
        self.fetchWorkbooksWithTags()
    }
    
    private func fetchAds() {
        self.networkUsecase.getBanners { [weak self] status, banners in
            switch status {
            case .SUCCESS:
                self?.banners = banners
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func fetchBestSellers() {
        self.networkUsecase.getBestSellers { [weak self] status, workbooks in
            switch status {
            case .SUCCESS:
                // MARK: test용 서버에서 filter 여부에 따라 previews 로직 분기처리
                if NetworkURL.forTest {
                    let filteredPreviews = self?.filteredPreviews(with: workbooks) ?? []
                    let count = min(10, filteredPreviews.count)
                    self?.bestSellers = Array(filteredPreviews.prefix(upTo: count))
                } else {
                    let count = min(10, workbooks.count)
                    self?.bestSellers = Array(workbooks.prefix(upTo: count))
                }
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func fetchPopup() {
        self.networkUsecase.getNoticePopup { [weak self] status, popupURL in
            guard UserDefaultsManager.lastViewedPopup != popupURL?.absoluteString else { return }
            
            switch status {
            case .SUCCESS:
                self?.popupURL = popupURL
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func fetchWorkbooksWithTags() {
        self.networkUsecase.getPreviews(tags: self.tags, text: "", page: 1, limit: 10) { [weak self] status, previews in
            switch status {
            case .SUCCESS:
                // MARK: test용 서버에서 filter 여부에 따라 previews 로직 분기처리
                if NetworkURL.forTest {
                    let filteredPreviews = self?.filteredPreviews(with: previews) ?? []
                    let count = min(10, filteredPreviews.count)
                    self?.workbooksWithTags = Array(filteredPreviews.prefix(upTo: count))
                } else {
                    let count = min(10, previews.count)
                    self?.workbooksWithTags = Array(previews.prefix(upTo: count))
                }
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func fetchRecentEnters() {
        self.networkUsecase.getUserBookshelfInfos(order: .solve) { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                let infos = infos.map { BookshelfInfo(info: $0) }.filter { $0.recentDate != nil }
                let count = min(10, infos.count)
                self?.recentEntered = Array(infos.prefix(upTo: count))
            default:
                self?.warning = (title: "구매내역 수신 에러", text: "네트워크 확인 후 재시도해주시기 바랍니다.")
            }
        }
    }
    
    private func fetchPurchased() {
        self.networkUsecase.getUserBookshelfInfos(order: .purchase) { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                let infos = infos.map { BookshelfInfo(info: $0) }
                let count = min(10, infos.count)
                self?.recentPurchased = Array(infos.prefix(upTo: count))
            default:
                self?.warning = (title: "구매내역 수신 에러", text: "네트워크 확인 후 재시도해주시기 바랍니다.")
            }
        }
    }
    
    private func fetchPracticeTests() {
        self.networkUsecase.searchWorkbookGroup(tags: nil, keyword: nil, page: nil, limit: nil) { [weak self] status, searchWorkbookGroups in
            switch status {
            case .SUCCESS:
                guard let workbookGroups = searchWorkbookGroups?.workbookGroups else {
                    self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                self?.workbookGroups = workbookGroups
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            self?.workbookDTO = workbook
        }
    }
}

// MARK: test 서버에서 출판사 제공용일 경우 filter 후 표시
extension HomeVM {
    private func filteredPreviews(with previews: [PreviewOfDB]) -> [PreviewOfDB] {
        guard let testCompany = NetworkURL.testCompany else {
            return previews
        }
        return previews.filter( { $0.publishCompany == testCompany })
    }
}
