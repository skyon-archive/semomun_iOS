//
//  BookshelfVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class BookshelfVM {
    private let networkUsecse: NetworkUsecase
    private let refreshQueue = OperationQueue()
    @Published private(set) var books: [Preview_Core] = []
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
    
    func fetchBooksFromCoredata() {
        guard let previews = CoreUsecase.fetchPreviews() else {
            print("no previews")
            return
        }
        self.books = previews
    }
    
    func fetchBooksFromNetwork() {
        // TODO: api 얘기해본 후 반영할 예정
    }
}
