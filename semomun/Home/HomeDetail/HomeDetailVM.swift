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
    typealias CellDataFetcher = (Int, @escaping ([T]?) -> Void) -> Void
    var isPaging = false
    /// VC에서 cell을 만들 때 가져다 사용하기 위한 프로퍼티
    private(set) var networkUsecase: S3ImageFetchable
    @Published private(set) var cellData: [T] = []
    @Published private(set) var warning: (title: String, text: String)?
    /* private */
    private var page = 1
    private let cellDataFetcher: CellDataFetcher
    
    init(networkUsecase: S3ImageFetchable, cellDataFetcher: @escaping CellDataFetcher) {
        self.networkUsecase = networkUsecase
        self.cellDataFetcher = cellDataFetcher
    }
    
    func fetch() {
        self.cellDataFetcher(self.page) { [weak self] data in
            guard let data = data else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.cellData = data
            self?.page += 1
        }
    }
    
    func fetchMore() {
        guard self.isPaging == false else { return }
        
        self.isPaging = true
        self.cellDataFetcher(self.page) { [weak self] data in
            guard let data = data else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.cellData.append(contentsOf: data)
            self?.page += 1
        }
    }
}
