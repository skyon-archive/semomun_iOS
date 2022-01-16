//
//  WorkbookViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine

final class WorkbookViewModel {
    private(set) var previewCore: Preview_Core?
    private(set) var workbookDTO: SearchWorkbook?
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var warning: String?
    @Published private(set) var sectionHeaders: [SectionHeader_Core]?
    @Published private(set) var sectionDTOs: [SectionOfDB]?
    
    init(previewCore: Preview_Core? = nil, workbookDTO: SearchWorkbook? = nil) {
        self.previewCore = previewCore
        self.workbookDTO = workbookDTO
    }
    
    func configureWorkbookInfo(isCoreData: Bool) {
        if isCoreData {
            guard let previewCore = self.previewCore else { return }
            self.workbookInfo = WorkbookInfo(previewCore: previewCore)
        } else {
            guard let workbookDTO = self.workbookDTO else { return }
            self.workbookInfo = WorkbookInfo(workbookDTO: workbookDTO.workbook)
        }
    }
    
    func fetchSectionHeaders() {
        guard let previewCore = self.previewCore,
              let sectionHeaders = CoreUsecase.fetchSectionHeaders(wid: Int(previewCore.wid)) else {
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
