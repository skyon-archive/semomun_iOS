//
//  BookshelfVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class BookshelfVM {
    private(set) var networkUsecse: NetworkUsecase
    @Published private(set) var books: [Preview_Core] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var loading: Bool = false
    
    init(networkUsecse: NetworkUsecase) {
        self.networkUsecse = networkUsecse
    }
    
    func reloadBookshelf(order: BookshelfVC.SortOrder) {
        print("reload Bookshelf, order: \(order)")
        guard let previews = CoreUsecase.fetchPreviews()?.filter({ $0.wgid != 0 }) else {
            print("no previews")
            return
        }
        
        if NetworkStatusManager.isConnectedToInternet() {
            NotificationCenter.default.post(name: .refreshBookshelf, object: nil)
        }
        
        // MARK: - 정렬로직 : order 값에 따라 -> Date 내림차순 정렬 (solved 값이 nil 인 경우 purchased 값으로 정렬)
        switch order {
        case .purchase:
            self.books = previews.sorted(by: { self.areBooksInDecreasingOrder(\.purchasedDate, $0, $1) })
        case .recent:
            self.books = previews.sorted(by: { self.areBooksInDecreasingOrder(\.recentDate, $0, $1) })
        case .alphabet:
            self.books = previews.sorted(by: { self.areBooksInDecreasingOrder(\.title, $1, $0) })
        }
    }
    
    /// Optional인 값을 비교하여 내림차순이면 True를 반환. nil은 어떤 값보다도 우선순위가 낮음. 비교대상이 모두 nil이면 purchasedDate의 최신순으로 정렬
    func areBooksInDecreasingOrder<Value: Comparable>(_ path: KeyPath<Preview_Core, Value?>, _ leftBook: Preview_Core, _ rightBook: Preview_Core) -> Bool {
        switch (leftBook[keyPath: path], rightBook[keyPath: path]) {
        case (let lhs?, let rhs?):
            return lhs > rhs
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            // 둘 다 값이 없는 경우 purchasedDate 사용
            guard let leftDate = leftBook.purchasedDate,
                  let rightDate = rightBook.purchasedDate else {
                // 여기로 오는 경우가 있으려나,,?
                return true
            }
            return leftDate > rightDate
        }
    }
    
    func fetchBooksFromNetwork() {
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        
        self.loading = true
        print("loading start")
        self.networkUsecse.getUserBookshelfInfos { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                if infos.isEmpty == false {
                    self?.syncBookshelf(infos: infos)
                } else {
                    self?.loading = false
                }
            default:
                self?.loading = false
                self?.warning = (title: "동기화 작업 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
    }
    
    private func syncBookshelf(infos: [BookshelfInfoOfDB]) {
        print("sync Bookshelf")
        let localBookWids = self.books.map(\.wid) // Local 내 저장되어있는 Workbook 의 wid 배열
        let userPurchases = infos.map { BookshelfInfo(info: $0) } // Network 에서 받은 사용자가 구매한 Workbook 들의 정보들
        // Local 내에 없는 book 정보들의 수를 센다
        let fetchCount: Int = userPurchases.filter { localBookWids.contains(Int64($0.wid)) == false }.count
        var currentCount: Int = 0
        print("---------- sync bookshelf ----------")
        userPurchases.forEach { info in
            // Local 내에 있는 Workbook 의 경우 recentDate 최신화 작업을 진행한다
            // migration 의 경우를 포함하여 purchasedDate 값도 최신화한다
            if localBookWids.contains(Int64(info.wid)) {
                let targetWorkbook = self.books.first { $0.wid == Int64(info.wid) }
                targetWorkbook?.updateDate(info: info, networkUsecase: self.networkUsecse)
                print("local preview(\(info.wid)) update complete")
            }
            // Local 내에 없는 경우 필요정보를 받아와 저장한다
            else {
                self.networkUsecse.getWorkbook(wid: info.wid) { [weak self] workbook in
                    let preview_core = Preview_Core(context: CoreDataManager.shared.context)
                    preview_core.setValues(workbook: workbook, info: info)
                    workbook.sections.forEach { section in
                        let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
                        sectionHeader_core.setValues(section: section)
                    }
                    
                    preview_core.fetchBookcover(uuid: workbook.bookcover, networkUsecase: self?.networkUsecse) { [weak self] in
                        print("save preview(\(info.wid)) complete")
                        currentCount += 1
                        
                        if currentCount == fetchCount {
                            CoreDataManager.saveCoreData()
                            self?.loading = false
                        }
                    }
                }
            }
        }
        
        // fetch 할 정보가 없을 경우 loading 종료
        if fetchCount == 0 {
            CoreDataManager.saveCoreData()
            self.loading = false
        }
    }
}
