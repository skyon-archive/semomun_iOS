//
//  WorkbookViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine

final class WorkbookViewModel {
    private var previewCore: Preview_Core
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var warning: String?
    @Published private(set) var sectionHeaders: [SectionHeader_Core]?
    
    init(previewCore: Preview_Core) {
        self.previewCore = previewCore
    }
    
    func configureWorkbookInfo() {
        self.workbookInfo = WorkbookInfo(previewCore: self.previewCore)
    }
    
    func fetchSectionHeaders() {
        guard let sectionHeaders = CoreUsecase.fetchSectionHeaders(wid: Int(self.previewCore.wid)) else {
            self.warning = "문제집 정보 로딩 실패"
            return
        }
        self.sectionHeaders = sectionHeaders
    }
    
    var count: Int {
        return self.sectionHeaders?.count ?? 0
    }
    
    func sectionHeader(idx: Int) -> SectionHeader_Core? {
        return self.sectionHeaders?[idx]
    }
}
