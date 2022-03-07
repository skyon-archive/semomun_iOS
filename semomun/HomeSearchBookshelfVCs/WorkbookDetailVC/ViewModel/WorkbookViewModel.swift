//
//  WorkbookViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine

typealias WorkbookVMNetworkUsecaes = (S3ImageFetchable & UserInfoFetchable & Purchaseable)

final class WorkbookViewModel {
    enum PopupType {
        case login, updateUserinfo, purchase
    }
    private let networkUsecase: WorkbookVMNetworkUsecaes
    private(set) var previewCore: Preview_Core?
    private(set) var workbookDTO: WorkbookOfDB?
    private(set) var credit: Int?
    @Published private(set) var tags: [String] = []
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var sectionHeaders: [SectionHeader_Core] = []
    @Published private(set) var sectionDTOs: [SectionHeaderOfDB] = []
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    @Published private(set) var bookcoverData: Data?
    
    init(previewCore: Preview_Core? = nil, workbookDTO: WorkbookOfDB? = nil, networkUsecase: WorkbookVMNetworkUsecaes) {
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
    
    private func fetchBookcoverImage(bookcover: UUID) {
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
                  self.warning = (title: "문제집 정보 로딩 실패", text: "앱 재설치 후 다시 시도하시기 바랍니다.")
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
    
    func purchaseWorkbook(bookcoverData: Data) {
        self.showLoader = true
        guard let workbook = self.workbookDTO else { return }
        // TODO: Purchase item 반영
        self.networkUsecase.purchaseItem(productIDs: [workbook.productID]) { [weak self] status, credit in
            switch status {
            case .SUCCESS:
                print("결제 후 잔액: \(credit!)")
                self?.saveWorkbookToCoreData(workbook: workbook, bookcoverData: bookcoverData)
            default:
                self?.warning = (title: "구매반영 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
        
    }
    
    private func saveWorkbookToCoreData(workbook: WorkbookOfDB, bookcoverData: Data) {
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
        let logined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        if !logined {
            self.popupType = .login
        } else {
            // MARK: App의 version 값으로 비교시 2.1, 2.2 업데이트마다 띄워지게 되므로 분기점을 따로 저장하는 식으로 수정
            let userCoreData = CoreUsecase.fetchUserInfo()
            if userCoreData?.phoneNumber?.isValidPhoneNumber == true {
                self.fetchUserCredit()
            } else {
                self.popupType = .updateUserinfo
            }
        }
    }
    
    private func fetchUserCredit() {
        self.networkUsecase.getUserCredit { [weak self] status, credit in
            switch status {
            case .SUCCESS:
                self?.credit = credit
                self?.popupType = .purchase
            default:
                self?.warning = (title: "잔액조회 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
    }
}
