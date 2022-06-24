//
//  WorkbookGroupDetailVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/21.
//

import Foundation
import Combine

typealias WorkbookGroupNetworkUsecase = (WorkbookGroupSearchable & UserPurchaseable & UserInfoFetchable)

final class WorkbookGroupDetailVM {
    /* public */
    private(set) var credit: Int?
    var isPurchased: Bool {
        return self.purchasedWorkbooks.isEmpty == false
    }
    @Published private(set) var purchasedWorkbooks: [Preview_Core] = [] {
        didSet {
            self.filteredNonPurchasedWorkbooks(from: self.nonPurchasedWorkbooks)
        }
    }
    @Published private(set) var nonPurchasedWorkbooks: [WorkbookOfDB] = []
    @Published private(set) var info: WorkbookGroupInfo
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var showLoader: Bool = false
    @Published private(set) var popupType: PopupType?
    @Published private(set) var purchaseWorkbook: WorkbookOfDB?
    /* private */
    enum PopupType {
        case login, updateUserinfo
    }
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
        self.networkUsecase = networkUsecase
        self.fetchPurchasedWorkbooks(wgid: self.info.wgid)
    }
}

// MARK: Public
extension WorkbookGroupDetailVM {
    func selectCoreWorkbook(to index: Int) {
        guard let selectedWorkbook = self.purchasedWorkbooks[safe: index] else {
            assertionFailure("out of index Error")
            return
        }
        // downloaded 상태에 따라 section show, download 로직 필요
    }
    
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
        guard let purchasedWid = self.purchaseWorkbook?.wid else { return }
        CoreUsecase.downloadWorkbook(wid: purchasedWid) { [weak self] success in
            guard let self = self, success else {
                self?.warning = (title: "네트워크 에러", text: "구매내역 반영에 실패하였습니다")
                return
            }
            
            self.fetchPurchasedWorkbooks(wgid: self.info.wgid)
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
        // fetch 완료된 후 fetchNonPurchasedWorkbooks fetch
        if self.nonPurchasedWorkbooks.isEmpty {
            self.fetchNonPurchasedWorkbooks(wgid: wgid)
        }
    }
    
    /// 해당 WorkbookGroup 에 속한 전체 WorkbookOfDB fetch
    /// purchasedWorkbooks 가 존재할 경우 filter 된다.
    private func fetchNonPurchasedWorkbooks(wgid: Int) {
        self.networkUsecase.searchWorkbookGroup(wgid: wgid) { [weak self] status, workbookGroupOfDB in
            switch status {
            case .SUCCESS:
                guard let workbookGroupOfDB = workbookGroupOfDB else { return }
                self?.filteredNonPurchasedWorkbooks(from: workbookGroupOfDB.workbooks)
            case .DECODEERROR:
                self?.warning = (title: "올바르지 않는 형식", text: "최신 버전으로 업데이트 해주세요")
            default:
                self?.warning = (title: "네트워크 에러", text: "네트워크 연결을 확인 후 다시 시도하세요")
            }
        }
    }
    
    private func filteredNonPurchasedWorkbooks(from workbooks: [WorkbookOfDB]) {
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
