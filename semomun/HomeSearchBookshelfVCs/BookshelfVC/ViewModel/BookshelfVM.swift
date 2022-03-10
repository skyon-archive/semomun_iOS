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
        print(order)
        guard let previews = CoreUsecase.fetchPreviews() else {
            print("no previews")
            return
        }
        // MARK: - 정렬로직 : order 값에 따라 -> Date 내림차순 정렬 (solved 값이 nil 인 경우 purchased 값으로 정렬)
        switch order {
        case .purchase:
            self.books = previews.sorted(by: { leftbook, rightbook in
                guard let leftDate = leftbook.purchasedDate,
                      let rightDate = rightbook.purchasedDate else {
                          return true
                      } // default: previews order
                return leftDate > rightDate
            })
        case .recent:
            self.books = previews.sorted(by: { leftbook, rightbook in
                guard let leftDate = leftbook.recentDate,
                      let rightDate = rightbook.recentDate else {
                          return leftbook.purchasedDate ?? Date() > rightbook.purchasedDate ?? Date()
                      } // default: purchasedDate
                return leftDate > rightDate
            })
        case .alphabet:
            self.books = previews.sorted(by: { leftbook, rightbook in
                guard let leftTitle = leftbook.title,
                      let rightTitle = rightbook.title else {
                          return true
                      } // default: previews order
                return leftTitle < rightTitle
            })
        }
    }
    
    func fetchBooksFromNetwork() {
        // TODO: Network 확인 로직 필요
        self.loading = true
        self.networkUsecse.getBookshelfInfos { [weak self] status, infos in
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
        let userPurchases = infos.map { BookshelfInfo(info: $0) }.sorted(by: { $0.wid != $1.wid ? ($0.wid < $1.wid) : ($0.purchased > $1.purchased) }) // wid 순으로 정렬, 동일 wid 시 purchased 내림차준 정렬
        var dict: [Int: [BookshelfInfo]] = [:]
        print("before: \(userPurchases)")
        userPurchases.forEach { info in
            if var values = dict[info.wid] {
                values.append(info)
            } else {
                dict[info.wid] = [info]
            }
        }
        var filteredUserPurchases: [BookshelfInfo] = []
        dict.values.forEach { infos in
            let maxDate = infos.map { $0.purchased }.max()
            infos.forEach { info in
                if info.purchased == maxDate {
                    filteredUserPurchases.append(info)
                }
            }
        }
        print("after: \(filteredUserPurchases)")
        self.loading = false
    }
}
