//
//  WorkbookGroupDetailVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/21.
//

import Foundation
import Combine

final class WorkbookGroupDetailVM {
    /* public */
    @Published private(set) var purchasedWorkbooks: [Preview_Core] = []
    @Published private(set) var nonPurchasedWorkbooks: [WorkbookOfDB] = []
    @Published private(set) var info: WorkbookGroupPreviewOfDB?
    /* private */
    init(info: WorkbookGroupPreviewOfDB) {
        self.info = info
        if UserDefaultsManager.isLogined {
            self.fetchPurchasedWorkbooks(wgid: info.wgid)
        } else {
            self.fetchNonPurchasedWorkbooks(wgid: info.wgid)
        }
    }
    /// CoreData 에 저장되어 있는 해당 WorkbookGroup 에서 사용자가 구매한 Preview_Core 들 fetch
    private func fetchPurchasedWorkbooks(wgid: Int) {
        // CoreData 에서 Preview_Core fetch 후 purchasedWorkbooks 반영
        // fetch 완료된 후 fetchNonPurchasedWorkbooks fetch
        self.fetchNonPurchasedWorkbooks(wgid: wgid)
    }
    
    /// 해당 WorkbookGroup 에 속한 전체 WorkbookOfDB fetch
    /// purchasedWorkbooks 가 존재할 경우 filter 된다.
    private func fetchNonPurchasedWorkbooks(wgid: Int) {
        let networkUsecase = NetworkUsecase(network: Network())
        let purchasedWids: [Int64] = self.purchasedWorkbooks.map(\.wid)
        networkUsecase.searchWorkbookGroup(wgid: wgid) { [weak self] status, workbookGroupOfDB in
            switch status {
            case .SUCCESS:
                guard let workbookGroupOfDB = workbookGroupOfDB else { return }
                self?.nonPurchasedWorkbooks = workbookGroupOfDB.workbooks
                    .filter({ purchasedWids.contains(Int64($0.wid)) == false })
            default:
                print("decoding error")
            }
        }
    }
}
