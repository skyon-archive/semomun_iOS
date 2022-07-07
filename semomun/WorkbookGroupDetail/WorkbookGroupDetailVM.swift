//
//  WorkbookGroupDetailVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/21.
//

import Foundation
import Combine

typealias WorkbookGroupNetworkUsecase = (WorkbookGroupSearchable & UserPurchaseable & UserInfoFetchable & UserWorkbooksFetchable & WorkbookSearchable & UserWorkbookGroupsFetchable & S3ImageFetchable & UserLogSendable & UserTestResultFetchable)

final class WorkbookGroupDetailVM {
    /* public */
    enum PopupType {
        case login, updateUserinfo
    }
    private(set) var credit: Int?
    private(set) var workbookGroupCore: WorkbookGroup_Core?
    @Published private(set) var purchasedWorkbooks: [Preview_Core] = []
    @Published private(set) var nonPurchasedWorkbooks: [WorkbookOfDB] = []
    @Published private(set) var testResults: [PrivateTestResultOfDB] = []
    @Published private(set) var info: WorkbookGroupInfo
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var popVC: (title: String, text: String)?
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    @Published private(set) var purchaseWorkbook: WorkbookOfDB?
    /* private */
    private let networkUsecase: WorkbookGroupNetworkUsecase
    
    /// DTO 를 통해 WorkbookGroupDetailVC 를 표시하는 경우
    /// 로그인 && 구매하지 않은 경우
    /// 로그인 상태가 아닌 경우
    init(dtoInfo: WorkbookGroupPreviewOfDB, networkUsecase: WorkbookGroupNetworkUsecase) {
        self.info = dtoInfo.info
        self.networkUsecase = networkUsecase
        self.fetchNonPurchasedWorkbooks(wgid: self.info.wgid)
    }
    
    /// CoreData 를 통해 WorkbookGroupDetailVC 를 표시하는 경우
    /// 로그인 && 구매한게 있는 경우
    init(coreInfo: WorkbookGroup_Core, networkUsecase: WorkbookGroupNetworkUsecase) {
        self.info = coreInfo.info
        self.workbookGroupCore = coreInfo
        self.networkUsecase = networkUsecase
        self.fetchPurchasedWorkbooks(wgid: self.info.wgid)
    }
}

// MARK: Public
extension WorkbookGroupDetailVM {
    func selectWorkbook(to index: Int) {
        guard let selectedWorkbook = self.nonPurchasedWorkbooks[safe: index] else {
            assertionFailure("out of index Error")
            return
        }
        
        let logined = UserDefaultsManager.isLogined
        if logined == false {
            self.popupType = .login
        } else {
            // MARK: App의 version 값으로 비교시 2.1, 2.2 업데이트마다 띄워지게 되므로 분기점을 따로 저장하는 식으로 수정
            let userCoreData = CoreUsecase.fetchUserInfo()
            if userCoreData?.phoneNumber?.isValidPhoneNumber == true {
                self.purchaseWorkbook(selectedWorkbook)
            } else {
                self.popupType = .updateUserinfo
            }
        }
    }
    
    func purchaseComplete() {
        guard let purchasedWorkbook = self.purchaseWorkbook else { return }
        self.showLoader = true
        
        self.networkUsecase.purchaseItem(productIDs: [purchasedWorkbook.productID]) { [weak self] status, credit in
            guard let self = self else { return }
            
            guard status == .SUCCESS else {
                self.showLoader = false
                self.warning = (title: "구매반영 실패", text: "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            
            // WorkbookGroup_Core 정보가 없는 경우 먼저 저장 (PracticeTestManager 로 전달이 필요하기에)
            if CoreUsecase.fetchWorkbookGroup(wgid: self.info.wgid) == nil {
                self.downloadWorkbookGroup()
            } else {
                self.downloadWorkbook()
            }
        }
    }
    
    func updateRecentDate(workbook: Preview_Core) {
        let updateDate = Date()
        workbook.setValue(updateDate, forKey: Preview_Core.Attribute.recentDate.rawValue)
        self.workbookGroupCore?.setValue(updateDate, forKey: WorkbookGroup_Core.Attribute.recentDate.rawValue)
        self.networkUsecase.sendWorkbookEnterLog(wid: Int(workbook.wid), datetime: updateDate)
        CoreDataManager.saveCoreData()
    }
    
    func fetchTestResults() {
        guard UserDefaultsManager.isLogined == true else { return }
        
        let wgid = self.info.wgid
        self.networkUsecase.getPrivateTestResults(wgid: wgid) { [weak self] _, testResults in
            self?.testResults = testResults
        }
    }
}

// MARK: Fetch
extension WorkbookGroupDetailVM {
    /// CoreData 에 저장되어 있는 해당 WorkbookGroup 에서 사용자가 구매한 Preview_Core 들 fetch
    private func fetchPurchasedWorkbooks(wgid: Int) {
        // CoreData 에서 Preview_Core fetch 후 purchasedWorkbooks 반영
        guard let purchasedWorkbooks = CoreUsecase.fetchPreviews(wgid: wgid) else {
            print("no purchased workbooks")
            return
        }
        
        self.purchasedWorkbooks = purchasedWorkbooks
        self.filterNonPurchasedWorkbooks(from: self.nonPurchasedWorkbooks)
        
        // fetch 완료된 후 fetchNonPurchasedWorkbooks fetch
        self.fetchNonPurchasedWorkbooks(wgid: wgid)
    }
    
    /// 해당 WorkbookGroup 에 속한 전체 WorkbookOfDB fetch
    /// purchasedWorkbooks 가 존재할 경우 filter 된다.
    private func fetchNonPurchasedWorkbooks(wgid: Int) {
        // dto 로 표시하는 상태이나 offline 의 경우 popVC 를 활성화
        // core 로 표시하는 상태이나 offline 의 경우 fetch 를 안한다 (경고 표시로직이 없어야 한다)
        guard NetworkStatusManager.isConnectedToInternet() == true else {
            if self.purchasedWorkbooks.isEmpty == true {
                self.popVC = (title: "네트워크 에러", text: "네트워크 연결을 확인 후 다시 시도하세요")
            }
            return
        }
        
        self.networkUsecase.searchWorkbookGroup(wgid: wgid) { [weak self] status, workbookGroupOfDB in
            switch status {
            case .SUCCESS:
                guard let workbookGroupOfDB = workbookGroupOfDB else { return }
                self?.filterNonPurchasedWorkbooks(from: workbookGroupOfDB.workbooks)
            case .DECODEERROR:
                self?.warning = (title: "올바르지 않는 형식", text: "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = (title: "네트워크 에러", text: "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func filterNonPurchasedWorkbooks(from workbooks: [WorkbookOfDB]) {
        let purchasedWids: [Int64] = self.purchasedWorkbooks.map(\.wid)
        self.nonPurchasedWorkbooks = workbooks
            .filter({ purchasedWids.contains(Int64($0.wid)) == false })
    }
}

// MARK: Purchase
extension WorkbookGroupDetailVM {
    private func purchaseWorkbook(_ workbook: WorkbookOfDB) {
        self.networkUsecase.getRemainingPay { [weak self] status, credit in
            switch status {
            case .SUCCESS:
                self?.credit = credit
                self?.purchaseWorkbook = workbook
            default:
                self?.warning = (title: "잔액조회 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
            }
        }
    }
}

// MARK: CoreData Download
extension WorkbookGroupDetailVM {
    private func downloadWorkbookGroup() {
        CoreUsecase.downloadWorkbookGroup(wgid: self.info.wgid, networkUsecase: self.networkUsecase) { workbookGroup in
            guard let workbookGroup = workbookGroup else {
                self.showLoader = false
                self.warning = (title: "다운로드 실패", text: "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            self.workbookGroupCore = workbookGroup
            self.downloadWorkbook()
        }
    }
    
    private func downloadWorkbook() {
        guard let purchasedWorkbook = self.purchaseWorkbook else { return }
        CoreUsecase.downloadWorkbook(wid: purchasedWorkbook.wid, networkUsecase: self.networkUsecase) { success in
            self.showLoader = false
            guard success else {
                self.warning = (title: "다운로드 실패", text: "네트워크 연결을 확인 후 다시 시도하세요")
                return
            }
            
            self.fetchPurchasedWorkbooks(wgid: self.info.wgid)
        }
    }
}
