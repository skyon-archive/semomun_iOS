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
        guard let previews = CoreUsecase.fetchPreviews() else {
            print("no previews")
            return
        }
        // MARK: - 정렬로직 : order 값에 따라 -> Date 내림차순 정렬 (solved 값이 nil 인 경우 purchased 값으로 정렬)
        switch order {
        case .purchase:
            self.books = previews.sorted(by: { self.areInIncreasingOrder(\.purchasedDate, leftBook: $0, rightBook: $1) })
        case .recent:
            self.books = previews.sorted(by: { self.areInIncreasingOrder(\.recentDate, leftBook: $0, rightBook: $1) })
        case .alphabet:
            self.books = previews.sorted(by: { self.areInIncreasingOrder(\.title, leftBook: $0, rightBook: $1) })
        }
    }
    
    func areInIncreasingOrder<Value: Comparable>(_ keyPath: KeyPath<Preview_Core, Value?>, leftBook: Preview_Core, rightBook: Preview_Core) -> Bool {
        switch (leftBook[keyPath: keyPath], rightBook[keyPath: keyPath]) {
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
                assertionFailure()
                return true
            }
            return leftDate > rightDate
        }
    }
    
    func fetchBooksFromNetwork(updateAll: Bool = false) {
        guard NetworkStatusManager.isConnectedToInternet() else { return }
        
        self.loading = true
        print("loading start")
        self.networkUsecse.getUserBookshelfInfos { [weak self] status, infos in
            switch status {
            case .SUCCESS:
                if infos.isEmpty == false {
                    if updateAll {
                        self?.updateAllBooks(infos: infos)
                    } else {
                        self?.syncBookshelf(infos: infos)
                    }
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
    
    // Migration 의 경우 coredata 상에 저장된 preview 도 모두 정보를 최신화 하는 함수
    private func updateAllBooks(infos: [BookshelfInfoOfDB]) {
        let userPurchases = infos.map { BookshelfInfo(info: $0) } // Network 에서 받은 사용자가 구매한 Workbook 들의 정보들
        guard userPurchases.isEmpty == false else {
            self.loading = false
            return
        }
        
        let taskGroup = DispatchGroup()
        print("---------- update All books ----------")
        
        userPurchases.forEach { info in
            taskGroup.enter()
            self.networkUsecse.getWorkbook(wid: info.wid) { [weak self] workbook in
                let targetWorkbook = self?.books.first { $0.wid == Int64(info.wid) }
                if targetWorkbook == nil {
                    print("CoreData 상에 없는 Workbook 정보 존재")
                    taskGroup.leave()
                }
                
                targetWorkbook?.setValues(workbook: workbook, info: info) // 저자, isbn 등 모두 새롭게 저장, 표지가 바뀔 수 있기에 표지도 fetch
                targetWorkbook?.fetchBookcover(uuid: workbook.bookcover, networkUsecase: self?.networkUsecse, completion: {
                    print("update preview(\(info.wid)) complete")
                    taskGroup.leave()
                })
            }
        }
        
        taskGroup.notify(queue: .main) {
            CoreDataManager.saveCoreData()
            self.loading = false
            return
        }
    }
}
