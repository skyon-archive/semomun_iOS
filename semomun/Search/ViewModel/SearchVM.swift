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
    @Published private(set) var favoriteTags: [TagOfDB] = []
    @Published private(set) var selectedTags: [TagOfDB] = []
    @Published private(set) var searchResultWorkbooks: [WorkbookPreviewOfDB] = []
    @Published private(set) var searchResultWorkbookGroups: [WorkbookGroupPreviewOfDB] = []
    @Published private(set) var workbook: WorkbookOfDB?
    @Published private(set) var warning: (title: String, text: String)?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func append(tag: TagOfDB) {
        self.selectedTags.append(tag)
    }
    
    func removeTag(index: Int) {
        guard index < self.selectedTags.count else { return }
        self.selectedTags.remove(at: index)
    }
    
    func removeAll() {
        self.selectedTags.removeAll()
    }
    
    func selectWorkbook(to wid: Int) {
        self.selectedWid = wid
    }
    
    func fetchWorkbook(wid: Int) {
        self.networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
            self?.workbook = workbook
        }
    }
    
    func fetchFavoriteTags() {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.warning = ("오프라인 상태입니다", "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.")
            return
        }
        
        self.networkUsecase.getTags(order: .popularity) { [weak self] status, tags in
            switch status {
            case .SUCCESS:
                self?.favoriteTags = Array(tags.prefix(10))
            case .DECODEERROR:
                self?.warning = ("올바르지 않는 형식", "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
}
