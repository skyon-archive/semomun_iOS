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
    @Published private(set) var testBooks: [TestBook] = []
    @Published private(set) var warning: (String, String)?
    
    init(networkUsecse: NetworkUsecase) {
        self.networkUsecse = networkUsecse
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
