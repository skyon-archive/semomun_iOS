//
//  WorkbookViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine

typealias WorkbookVMNetworkUsecaes = (S3ImageFetchable & UserInfoFetchable & UserPurchaseable & UserLogSendable)
typealias WorkbookCellInfo = (title: String, text: String)

final class WorkbookDetailVM {
    enum PopupType {
        case login, updateUserinfo, purchase
    }
    private let networkUsecase: WorkbookVMNetworkUsecaes
    private(set) var previewCore: Preview_Core?
    private(set) var workbookDTO: WorkbookOfDB?
    private(set) var credit: Int?
    @Published private(set) var tags: [String] = []
    @Published private(set) var workbookInfo: WorkbookInfo?
    @Published private(set) var workbookCellInfos: [WorkbookCellInfo] = []
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var sectionHeaders: [SectionHeader_Core] = []
    @Published private(set) var sectionDTOs: [SectionHeaderOfDB] = []
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    @Published private(set) var bookcoverData: Data?
    
    @Published private(set) var selectedSectionsForDelete: [Int] = []
    @Published private(set) var downloadQueue: [Int] = []
    
    init(previewCore: Preview_Core? = nil, workbookDTO: WorkbookOfDB? = nil, networkUsecase: WorkbookVMNetworkUsecaes) {
        self.networkUsecase = networkUsecase
        self.previewCore = previewCore
        self.workbookDTO = workbookDTO
    }
    
    func updateRecentDate() {
        guard let wid = self.previewCore?.wid else { return }
        let updateDate = Date()
        self.previewCore?.setValue(updateDate, forKey: Preview_Core.Attribute.recentDate.rawValue)
        self.networkUsecase.sendWorkbookEnterLog(wid: Int(wid), datetime: updateDate)
        CoreDataManager.saveCoreData()
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
        }
        self.configureWorkbookCellInfos()
    }
    
    func fetchBookcoverImage(bookcover: UUID) {
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
    
    func purchaseWorkbook() {
        self.showLoader = true
        guard let workbook = self.workbookDTO else { return }
        
        self.networkUsecase.purchaseItem(productIDs: [workbook.productID]) { [weak self] status, credit in
            switch status {
            case .SUCCESS:
                if let credit = credit,
                   let userInfo = CoreUsecase.fetchUserInfo() {
                    print("구매 후 잔액: \(credit)")
                    userInfo.updateCredit(credit)
                }
                self?.showLoader = false
            default:
                self?.warning = (title: "구매반영 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
    }
    
    func switchPurchase() {
        let logined = UserDefaultsManager.isLogined
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
        self.networkUsecase.getRemainingPay { [weak self] status, credit in
            switch status {
            case .SUCCESS:
                self?.credit = credit
                self?.popupType = .purchase
            default:
                self?.warning = (title: "잔액조회 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
    }
    
    private func configureWorkbookCellInfos() {
        guard let workbookInfo = self.workbookInfo else { return }
        
        var infos: [WorkbookCellInfo] = []
        infos.append(WorkbookCellInfo("저자", workbookInfo.author))
        infos.append(WorkbookCellInfo("출판사", workbookInfo.publisher))
        infos.append(WorkbookCellInfo("출간일", workbookInfo.releaseDate))
        infos.append(WorkbookCellInfo("파일크기", workbookInfo.fileSize))
        if workbookInfo.isbn != "" {
            infos.append(WorkbookCellInfo("ISBN", workbookInfo.isbn))
        }
        self.workbookCellInfos = infos
    }
}

extension WorkbookDetailVM {
    var downloadableCount: Int {
        return self.sectionHeaders.filter({ $0.downloaded == false }).count
    }
    
    func downloadSuccess(index: Int) {
        // 모두 다운로드 상태인 경우 다음 download 로직 실행
    }
    
    func selectSection(index: Int) {
        if self.selectedSectionsForDelete.contains(index) {
            self.selectedSectionsForDelete.removeAll{ $0 == index }
        } else {
            self.selectedSectionsForDelete.append(index)
        }
    }
    
    func selectAllSectionsForDelete() {
        /// 전체 선택 해제
        guard self.selectedSectionsForDelete.isEmpty == true else {
            self.selectedSectionsForDelete = []
            return
        }
        /// 전체 선택
        var selectedIndexes: [Int] = []
        for (idx, section) in self.sectionHeaders.enumerated() {
            if section.downloaded { selectedIndexes.append(idx) }
        }
        self.selectedSectionsForDelete = selectedIndexes
    }
    
    func downloadAllSections() {
        
    }
    
    func deleteSelectedSections() {
        
    }
}
