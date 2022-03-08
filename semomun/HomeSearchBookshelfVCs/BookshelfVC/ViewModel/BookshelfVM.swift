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
    @Published private(set) var warning: (String, String)?
    
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
        // TODO: api 얘기해본 후 반영할 예정
    }
}
