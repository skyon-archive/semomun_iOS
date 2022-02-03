//
//  SearchVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import Foundation
import Combine

final class SearchVM {
    private let networkUsecase: NetworkUsecase
    private let searchQueue = OperationQueue()
    private(set) var selectedWid: Int?
    @Published private(set) var tags: [String] = []
    @Published private(set) var workbook: SearchWorkbook?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func tag(index: Int) -> String {
        return self.tags[index]
    }
    
    func append(tag: String) {
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
        self.networkUsecase.downloadWorkbook(wid: wid) { [weak self] searchWorkbook in
            self?.workbook = searchWorkbook
        }
    }
}
