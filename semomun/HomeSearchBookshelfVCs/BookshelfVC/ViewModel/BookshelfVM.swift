//
//  BookshelfVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import Foundation
import Combine

final class BookshelfVM {
    private let refreshQueue = OperationQueue()
    private(set) var networkUsecse: NetworkUsecase
    @Published private(set) var books: [Preview_Core] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecse: NetworkUsecase) {
        self.networkUsecse = networkUsecse
        self.configureObservation()
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .refreshBookshelf, object: nil, queue: self.refreshQueue) { [weak self] _ in
            self?.fetchBooksFromCoredata()
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
