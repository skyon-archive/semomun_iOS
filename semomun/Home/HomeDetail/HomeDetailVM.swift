//
//  HomeDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import Foundation
import Combine

final class HomeDetailVM<T: HomeBookcoverConfigurable> {
    /* public */
    /// Int값은 페이지네이션에서 page값으로 사용
    typealias CellDataFetcher = (Int, ([T]) -> Void) -> Void
    var isPaging = false
    @Published private(set) var cellData: [T] = []
    /* private */
    private var page = 0
    private let cellDataFetcher: CellDataFetcher
    
    init(cellDataFetcher: @escaping CellDataFetcher) {
        self.cellDataFetcher = cellDataFetcher
    }
    
    func fetch() {
        self.cellDataFetcher(self.page) { [weak self] data in
            self?.cellData = data
            self?.page += 1
        }
    }
    
    func fetchMore() {
        guard self.isPaging == false else { return }
        
        self.isPaging = true
        self.cellDataFetcher(self.page) { [weak self] data in
            self?.cellData.append(contentsOf: data)
            self?.page += 1
        }
    }
}
