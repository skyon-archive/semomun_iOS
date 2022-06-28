//
//  SearchVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import Foundation
import Combine

final class SearchVM {
    private let searchQueue = OperationQueue()
    private(set) var selectedWid: Int?
    private(set) var networkUsecase: NetworkUsecase
    @Published private(set) var tags: [TagOfDB] = []
    @Published private(set) var workbook: WorkbookOfDB?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func append(tag: TagOfDB) {
        self.tags.append(tag)
    }
    
    func removeTag(index: Int) {
        self.tags.remove(at: index)
    }
    
    func removeAll() {
        self.tags.removeAll()
    }
    
    func selectWorkbook(to wid: Int) {
        self.selectedWid = wid
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            self?.workbook = workbook
        }
    }
}
