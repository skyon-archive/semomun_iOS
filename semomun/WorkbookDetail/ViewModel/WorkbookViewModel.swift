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
    
    init(previewCore: Preview_Core) {
        self.previewCore = previewCore
    }
    
    func configureWorkbookInfo() {
        self.workbookInfo = WorkbookInfo(previewCore: self.previewCore)
    }
}
