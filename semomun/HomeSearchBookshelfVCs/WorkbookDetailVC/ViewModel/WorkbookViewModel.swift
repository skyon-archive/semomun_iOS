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
    private let networkUsecase: NetworkUsecase
    private(set) var previewCore: Preview_Core?
    private(set) var workbookDTO: WorkbookOfDB?
    @Published private(set) var tags: [String] = []
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var warning: String?
    @Published private(set) var sectionHeaders: [SectionHeader_Core] = []
    @Published private(set) var sectionDTOs: [SectionHeaderOfDB] = []
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    @Published private(set) var bookcoverData: Data?
    
    init(previewCore: Preview_Core? = nil, workbookDTO: WorkbookOfDB? = nil, networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.previewCore = previewCore
        self.workbookDTO = workbookDTO
    }
    
    func configureWorkbookInfo(isCoreData: Bool) {
        if isCoreData {
            guard let previewCore = self.previewCore else { return }
            self.workbookInfo = WorkbookInfo(previewCore: previewCore)
            self.tags = previewCore.tags
        } else {
            guard let workbookDTO = self.workbookDTO else { return }
            self.workbookInfo = WorkbookInfo(workbookDTO: workbookDTO)
            self.tags = workbookDTO.tags.map(\.name)
            self.fetchBookcoverImage(bookcover: workbookDTO.bookcover)
        }
    }
    
    private func fetchBookcoverImage(bookcover: String) {
        self.networkUsecase.getImageFromS3(uuid: bookcover, type: .bookcover) { [weak self] status, data in
            if status == .FAIL {
                print("WorkbookDetailVM: GET image fail")
            }
            self?.bookcoverData = data
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
            return self.sectionHeaders.count
        } else {
            return self.sectionDTOs.count
        }
    }
    
    func saveWorkbook(bookcoverData: Data) {
        self.showLoader = true
        guard let workbook = self.workbookDTO else { return }
        DispatchQueue.main.async { [weak self] in
            // MARK: - Save Preview
            let preview_core = Preview_Core(context: CoreDataManager.shared.context)
            preview_core.setValues(workbook: workbook, bookcoverData: bookcoverData)
            // MARK: - Save Sections
            workbook.sections.forEach { section in
                let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
                sectionHeader_core.setValues(section: section)
            }
            
            CoreDataManager.saveCoreData()
            print("save complete")
            self?.showLoader = false
        }
    }
    
    func switchPurchase() {
//        let logined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
//        if !logined {
//            self.popupType = .login
//        } else {
//            // MARK: App의 version 값으로 비교시 2.1, 2.2 업데이트마다 띄워지게 되므로 분기점을 따로 저장하는 식으로 수정
//            let userCoreData = CoreUsecase.fetchUserInfo()
//            if userCoreData?.phoneNumber?.isValidPhoneNumberWithCountryCode == true {
//                self.popupType = .purchase
//            } else {
//                self.popupType = .purchase
//            }
//        }
        self.popupType = .purchase
    }
}
