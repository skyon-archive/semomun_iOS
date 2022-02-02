//
//  BookshelfVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

typealias TestBook = (title: String, author: String, publisher: String)

final class BookshelfVM {
    private let networkUsecse: NetworkUsecase
    private let refreshQueue = OperationQueue()
    @Published private(set) var testBooks: [TestBook] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecse: NetworkUsecase) {
        self.networkUsecse = networkUsecse
        self.configureObservation()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .refreshBookshelf, object: nil, queue: self.refreshQueue) { [weak self] notification in
            guard let wid = notification.userInfo?["wid"] as? Int else { return }
            // coreData fetch -> wid: WorkbookDetailVC 전환 로직 필요
            print(wid)
        }
    }
    
    func fetchBooks() {
        self.networkUsecse.getBooks { [weak self] status, testBooks in
            switch status {
            case .SUCCESS:
                self?.testBooks = testBooks
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
}
