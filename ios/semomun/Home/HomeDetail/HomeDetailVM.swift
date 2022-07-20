//
//  HomeDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import Foundation
import Combine

typealias HomeDetailVMNetworkUsecase = (S3ImageFetchable & WorkbookSearchable)

class HomeDetailVM<T: HomeBookcoverCellInfo> {
    /* public */
    typealias CellDataCompletion = ([T]?) -> Void
    /// Int값은 페이지네이션에서 page값으로 사용
    typealias CellDataFetcher = (Int, DropdownOrderButton.SearchOrder, @escaping CellDataCompletion) -> Void
    
    var isPaging = false
    /// VC에서 cell을 만들 때 가져다 사용하기 위한 프로퍼티
    private(set) var networkUsecase: HomeDetailVMNetworkUsecase
    @Published private(set) var cellData: [T] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var workbookDTO: WorkbookOfDB?
    /* private */
    private var page = 1
    private var cellDataFetcher: CellDataFetcher
    private var searchOrder: DropdownOrderButton.SearchOrder = .recentUpload
    private var isLastPage = false
    
    init(networkUsecase: HomeDetailVMNetworkUsecase, cellDataFetcher: @escaping CellDataFetcher) {
        self.networkUsecase = networkUsecase
        self.cellDataFetcher = cellDataFetcher
    }
    
    func fetch() {
        self.page = 1
        self.isPaging = true
        self.cellDataFetcher(self.page, self.searchOrder) { [weak self] data in
            guard let data = data else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.isLastPage = data.isEmpty
            self?.cellData = data
            self?.page += 1
        }
    }
    
    func fetchMore() {
        guard self.isPaging == false, self.isLastPage == false else { return }
        
        self.isPaging = true
        self.cellDataFetcher(self.page, self.searchOrder) { [weak self] data in
            guard let data = data else {
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self?.isLastPage = data.isEmpty
            self?.cellData.append(contentsOf: data)
            self?.page += 1
        }
    }
    
    func changeSearchOrder(to order: DropdownOrderButton.SearchOrder) {
        self.searchOrder = order
        self.fetch()
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            self?.workbookDTO = workbook
        }
    }
}
