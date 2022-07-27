//
//  BookshelfVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class BookshelfVM {
    /* public */
    private(set) var networkUsecase: NetworkUsecase
    @Published private(set) var workbooksForRecent: [WorkbookCellInfo] = []
    @Published private(set) var workbooks: [WorkbookCellInfo] = []
    @Published private(set) var workbookGroups: [WorkbookGroupCellInfo] = []
    @Published private(set) var warning: (title: String, text: String)?
    var currentWorkbooksOrder: DropdownOrderButton.BookshelfOrder = .recentPurchase
    var currentWorkbookGroupsOrder: DropdownOrderButton.BookshelfOrder = .recentRead
    var filteredSubject: DropdownButton.BookshelfSubject = .all
    /* private */
    private var workbooksNotFiltered: [WorkbookCellInfo] = []
    
    init(networkUsecse: NetworkUsecase) {
        self.networkUsecase = networkUsecse
    }
}

// MARK: Public
extension BookshelfVM {
    /// tab 이 변경될 때 내부 CoreData 를 fetch 및 정렬해서 표시
    func refresh(tab: BookshelfVC.Tab) {
        guard UserDefaultsManager.isLogined == true else { return }
        switch tab {
        case .home:
            self.currentWorkbooksOrder = .recentPurchase
            self.currentWorkbookGroupsOrder = .recentRead
            self.filteredSubject = .all
            self.reloadWorkbooks()
            self.reloadWorkbooksForRecent()
            self.reloadWorkbookGroups()
        case .workbook:
            self.filteredSubject = .all
            self.reloadWorkbooks()
            self.fetchWorkbooks()
        case .practiceTest:
            self.filteredSubject = .all
            self.reloadWorkbookGroups()
            self.fetchWorkbookGroups()
        }
    }
    
    func reloadWorkbookGroups() {
        guard UserDefaultsManager.isLogined == true else { return }
        guard let workbookGroups = CoreUsecase.fetchWorkbookGroups() else {
            print("no workbookGoups")
            return
        } // 이 함수를 빠져나가면 workbookGroups 는 제거되어야 한다.
        
        if NetworkStatusManager.isConnectedToInternet() {
            NotificationCenter.default.post(name: .refreshBookshelf, object: nil) // HomeVM 에서 수신받아 reload 후 표시 연결
        }
        
        // MARK: - 정렬로직 : order 값에 따라 -> Date 내림차순 정렬 (solved 값이 nil 인 경우 purchased 값으로 정렬)
        switch self.currentWorkbookGroupsOrder {
        case .recentPurchase:
            self.workbookGroups = workbookGroups.sorted(by: { self.areWorkbookGroupsInDecreasingOrder(\.purchasedDate, $0, $1) }).map(\.cellInfo)
        case .recentRead:
            self.workbookGroups = workbookGroups.sorted(by: { self.areWorkbookGroupsInDecreasingOrder(\.recentDate, $0, $1) }).map(\.cellInfo)
        case .titleDescending:
            self.workbookGroups = workbookGroups.sorted(by: { self.areWorkbookGroupsInDecreasingOrder(\.title, $0, $1) }).map(\.cellInfo)
        case .titleAscending:
            self.workbookGroups = workbookGroups.sorted(by: { self.areWorkbookGroupsInDecreasingOrder(\.title, $1, $0) }).map(\.cellInfo)
        }
                                                        }
     
    func reloadWorkbooks() {
        guard UserDefaultsManager.isLogined == true else { return }
        guard let workbooks = CoreUsecase.fetchPreviews() else {
            print("no workbooks")
            return
        }
        self.workbooksNotFiltered = workbooks.map { $0.cellInfo }
        let filteredWorkbooks = workbooks.filter({ $0.wgid == 0 })
        
        if NetworkStatusManager.isConnectedToInternet() {
            NotificationCenter.default.post(name: .refreshBookshelf, object: nil) // HomeVM 에서 수신받아 reload 후 표시 연결
        }
        
        // MARK: - 정렬로직 : order 값에 따라 -> Date 내림차순 정렬 (solved 값이 nil 인 경우 purchased 값으로 정렬)
        var beforeSubjectFiltered: [WorkbookCellInfo] = []
        switch self.currentWorkbooksOrder {
        case .recentPurchase:
            beforeSubjectFiltered = filteredWorkbooks.sorted(by: { self.areWorkbooksInDecreasingOrder(\.purchasedDate, $0, $1) }).map(\.cellInfo)
        case .recentRead:
            beforeSubjectFiltered = filteredWorkbooks.sorted(by: { self.areWorkbooksInDecreasingOrder(\.recentDate, $0, $1) }).map(\.cellInfo)
        case .titleDescending:
            beforeSubjectFiltered = filteredWorkbooks.sorted(by: { self.areWorkbooksInDecreasingOrder(\.title, $0, $1) }).map(\.cellInfo)
        case .titleAscending:
            beforeSubjectFiltered = filteredWorkbooks.sorted(by: { self.areWorkbooksInDecreasingOrder(\.title, $1, $0) }).map(\.cellInfo)
        }
        
        if self.filteredSubject == .all {
            self.workbooks = beforeSubjectFiltered
        } else {
            self.workbooks = beforeSubjectFiltered.filter { $0.tags.contains(self.filteredSubject.rawValue) }
        }
    }
    
    func reloadWorkbooksForRecent() {
        self.workbooksForRecent = self.workbooks.filter { $0.recentDate != nil }.sorted(by: { $0.recentDate! > $1.recentDate! })
    }
    
    /// 두 API, API 내 wgid, wid 개수별 fetch 로직이 비동기로 이뤄진 후 saveCore 할 경우 데이터가 비정상적으로 저장되는 이슈가 발생
    /// 따라서 두 API 의 내부 wgid, wid 를 통한 fetch 까지 모두 끝난 경우를 인지하여 한번의 saveCoreData 수행, collectionView.reload 로 연결
    func fetchBookshelf() {
        guard UserDefaultsManager.isLogined == true else { return }
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        let taskGroup = DispatchGroup()
        
        taskGroup.enter()
        self.fetchWorkbookGroupsFromNetwork() {
            taskGroup.leave()
        }
        
        taskGroup.enter()
        self.fetchWorkbooksFromNetwork() {
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main) {
            CoreDataManager.saveCoreData()
            self.reloadWorkbookGroups()
            self.reloadWorkbooks()
            self.reloadWorkbooksForRecent()
        }
    }
    
    func fetchWorkbooks() {
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        self.fetchWorkbooksFromNetwork { [weak self] in
            CoreDataManager.saveCoreData()
            self?.reloadWorkbooks()
        }
    }
    
    func fetchWorkbookGroups() {
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        self.fetchWorkbookGroupsFromNetwork { [weak self] in
            CoreDataManager.saveCoreData()
            self?.reloadWorkbookGroups()
        }
    }
    
    func fetchWorkbookGroupsFromNetwork(completion: @escaping (() -> Void)) {
        self.networkUsecase.getUserWorkbookGroupInfos { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                if infos.isEmpty == false {
                    self?.syncWorkbookGroups(infos: infos, completion: completion)
                } else {
                    completion()
                }
            default:
                self?.warning = (title: "동기화 작업 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                completion()
            }
        }
    }
    
    func fetchWorkbooksFromNetwork(completion: @escaping (() -> Void)) {
        self.networkUsecase.getUserBookshelfInfos { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                if infos.isEmpty == false {
                    self?.syncWorkbooks(infos: infos, completion: completion)
                } else {
                    completion()
                }
            default:
                self?.warning = (title: "동기화 작업 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                completion()
            }
        }
    }
    
    func resetForLogout() {
        self.workbooksForRecent = []
        self.workbooks = []
        self.workbookGroups = []
    }
}

// MARK: Private
extension BookshelfVM {
    /// Optional인 값을 비교하여 내림차순이면 True를 반환. nil은 어떤 값보다도 우선순위가 낮음. 비교대상이 모두 nil이면 purchasedDate의 최신순으로 정렬
    private func areWorkbookGroupsInDecreasingOrder<Value: Comparable>(_ path: KeyPath<WorkbookGroup_Core, Value?>, _ leftGroup: WorkbookGroup_Core, _ rightGroup: WorkbookGroup_Core) -> Bool {
        switch (leftGroup[keyPath: path], rightGroup[keyPath: path]) {
        case (let lhs?, let rhs?):
            return lhs > rhs
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            // 둘 다 값이 없는 경우 purchasedDate 사용
            guard let leftDate = leftGroup.purchasedDate,
                  let rightDate = rightGroup.purchasedDate else {
                // 여기로 오는 경우가 있으려나,,?
                return true
            }
            return leftDate > rightDate
        }
    }
    /// Optional인 값을 비교하여 내림차순이면 True를 반환. nil은 어떤 값보다도 우선순위가 낮음. 비교대상이 모두 nil이면 purchasedDate의 최신순으로 정렬
    private func areWorkbooksInDecreasingOrder<Value: Comparable>(_ path: KeyPath<Preview_Core, Value?>, _ leftWorkbook: Preview_Core, _ rightWorkbook: Preview_Core) -> Bool {
        switch (leftWorkbook[keyPath: path], rightWorkbook[keyPath: path]) {
        case (let lhs?, let rhs?):
            return lhs > rhs
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            // 둘 다 값이 없는 경우 purchasedDate 사용
            guard let leftDate = leftWorkbook.purchasedDate,
                  let rightDate = rightWorkbook.purchasedDate else {
                // 여기로 오는 경우가 있으려나,,?
                return true
            }
            return leftDate > rightDate
        }
    }
    
    private func syncWorkbookGroups(infos userPurchases: [PurchasedWorkbookGroupInfoOfDB], completion: @escaping (() -> Void)) {
        print("sync workbookGroups")
        let localWorkbookGroupWgids = self.workbookGroups.map(\.wgid)
        // Local 내에 없는 book 정보들의 수를 센다
        let fetchCount: Int = userPurchases.filter { localWorkbookGroupWgids.contains($0.wgid) == false }.count
        var currentCount: Int = 0
        print("---------- sync workbookGroups ----------")
        userPurchases.forEach { info in
            // Local 내에 있는 WorkbookGroup 의 경우 recentDate 최신화 작업을 진행한다
            // migration 의 경우를 포함하여 purchasedDate 값도 최신화한다
            if localWorkbookGroupWgids.contains(info.wgid) {
                if let targetWorkbookGroup = CoreUsecase.fetchWorkbookGroup(wgid: info.wgid) {
                    targetWorkbookGroup.updateInfos(purchasedInfo: info)
                    print("local workbookGroup(\(info.wgid)) update complete")
                }
            }
            // Local 내에 없는 경우 필요정보를 받아와 저장한다
            else {
                self.networkUsecase.searchWorkbookGroup(wgid: info.wgid) { [weak self] status, workbookGroup in
                    guard status == .SUCCESS, let workbookGroup = workbookGroup else {
                        print("fetch workbookGroup(\(info.wgid)) error")
                        self?.warning = (title: "동기화 작업 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                        completion()
                        return
                    }
                    
                    let workbookGroup_Core = WorkbookGroup_Core(context: CoreDataManager.shared.context)
                    workbookGroup_Core.setValues(workbookGroup: workbookGroup, purchasedInfo: info)
                    // workbookGroup 내 workbook 들은 아래 syncWorkbooks 를 통해 save 된다
                    
                    workbookGroup_Core.fetchGroupcover(uuid: workbookGroup.groupCover, networkUsecase: self?.networkUsecase) {
                        print("save workbookGroup(\(info.wgid)) complete")
                        currentCount += 1
                        
                        if currentCount == fetchCount {
                            completion()
                        }
                    }
                }
            }
        }
        
        // fetch 할 정보가 없을 경우 loading 종료
        if fetchCount == 0 {
            completion()
        }
    }
    
    private func syncWorkbooks(infos: [BookshelfInfoOfDB], completion: @escaping (() -> Void)) {
        print("sync workbooks")
        let localBookWids = self.workbooksNotFiltered.map(\.wid) // Local 내 저장되어있는 Workbook 의 wid 배열
        let userPurchases = infos.map { BookshelfInfo(info: $0) } // Network 에서 받은 사용자가 구매한 Workbook 들의 정보들
        // Local 내에 없는 workbook 정보들의 수를 센다
        let fetchCount: Int = userPurchases.filter { localBookWids.contains($0.wid) == false }.count
        var currentCount: Int = 0
        print("---------- sync bookshelf ----------")
        userPurchases.forEach { info in
            // Local 내에 있는 Workbook 의 경우 recentDate 최신화 작업을 진행한다
            // migration 의 경우를 포함하여 purchasedDate 값도 최신화한다
            if localBookWids.contains(info.wid) {
                if let targetWorkbook = CoreUsecase.fetchPreview(wid: info.wid) {
                    targetWorkbook.updateDate(info: info, networkUsecase: self.networkUsecase)
                    print("local preview(\(info.wid)) update complete")
                }
            }
            // Local 내에 없는 경우 필요정보를 받아와 저장한다
            else {
                self.networkUsecase.getWorkbook(wid: info.wid) { [weak self] workbook in
                    guard let workbook = workbook else {
                        print("fetch preview(\(info.wid)) error")
                        self?.warning = (title: "동기화 작업 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                        completion()
                        return
                    }
                    
                    let preview_core = Preview_Core(context: CoreDataManager.shared.context)
                    preview_core.setValues(workbook: workbook, info: info)
                    workbook.sections.forEach { section in
                        let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
                        sectionHeader_core.setValues(section: section)
                    }
                    
                    preview_core.fetchBookcover(uuid: workbook.bookcover, networkUsecase: self?.networkUsecase) {
                        print("save preview(\(info.wid)) complete")
                        currentCount += 1
                        
                        if currentCount == fetchCount {
                            completion()
                        }
                    }
                }
            }
        }
        
        // fetch 할 정보가 없을 경우 loading 종료
        if fetchCount == 0 {
            completion()
        }
    }
}
