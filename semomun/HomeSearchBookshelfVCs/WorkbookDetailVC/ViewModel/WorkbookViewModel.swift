//
//  WorkbookViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine

final class WorkbookViewModel {
    enum PopupType {
        case login, updateUserinfo, purchase
    }
    private let tags: [String] = []
    private(set) var previewCore: Preview_Core?
    private(set) var workbookDTO: SearchWorkbook?
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var warning: String?
    @Published private(set) var sectionHeaders: [SectionHeader_Core]?
    @Published private(set) var sectionDTOs: [SectionOfDB]?
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    
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
        self.sectionHeaders = sectionHeaders.sorted(by: { $0.sid < $1.sid })
    }
    
    func fetchSectionDTOs() {
        guard let workbookDTO = self.workbookDTO else { return }
        self.sectionDTOs = workbookDTO.sections
    }
    
    func count(isCoreData: Bool) -> Int {
        if isCoreData {
            return self.sectionHeaders?.count ?? 0
        } else {
            return self.sectionDTOs?.count ?? 0
        }
    }
    
    func sectionHeader(idx: Int) -> SectionHeader_Core? {
        return self.sectionHeaders?[idx]
    }
    
    func sectionDTO(idx: Int) -> SectionOfDB? {
        return self.sectionDTOs?[idx]
    }
    
    func tag(idx: Int) -> String {
        return self.tags[idx]
    }
    
    func saveWorkbook() {
        self.showLoader = true
        guard let searchWorkbook = self.workbookDTO else { return }
        let wid = searchWorkbook.workbook.wid
        DispatchQueue.main.async { [weak self] in
            // MARK: - Save Preview
            let preview_core = Preview_Core(context: CoreDataManager.shared.context)
            preview_core.setValues(searchWorkbook: searchWorkbook)
            // MARK: - Save Sections
            searchWorkbook.sections.forEach { section in
                let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
                sectionHeader_core.setValues(section: section, baseURL: NetworkURL.sectioncoverImageDirectory(.large), wid: wid)
            }
            
            CoreDataManager.saveCoreData()
            print("save complete")
            self?.showLoader = false
        }
    }
    
    func switchPurchase() {
        let logined = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.logined) as? Bool ?? false
        let userVersion = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.userVersion) as? String ?? "1.1.1"
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0"
        
        if !logined {
            self.popupType = .login
        } else {
            if userVersion.compare(version, options: .numeric) == .orderedAscending {
                self.popupType = .updateUserinfo
            } else {
                self.popupType = .purchase
            }
        }
    }
}
