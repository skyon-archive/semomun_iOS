//
//  WorkbookGroupDetailVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/21.
//

import Foundation
import Combine

final class WorkbookGroupDetailVM {
    @Published private(set) var purchasedWorkbooks: [Preview_Core] = []
    @Published private(set) var nonPurchasedWorkbooks: [WorkbookPreviewOfDB] = []
    
    init() {
        let networkUsecase = NetworkUsecase(network: Network())
        networkUsecase.searchWorkbookGroup(wgid: 0) { status, workbookGroupOfDB in
            switch status {
            case .SUCCESS:
                guard let workbookGroupOfDB = workbookGroupOfDB else {
                    return
                }
                dump(workbookGroupOfDB)
            default:
                print("decoding error")
            }
        }
    }
    // login 상태인 경우
        // CoreData 상에 wgid 값을 토대로 [Workbook] fetch
        // 2번 api 를 통해 전체 정보를 fetch
        // [Workbook].count > 0 인 경우
            // 나의 모의고사 section 생성, 정보 표시
                // cell.configure(CoreData)
        // 0개인 경우
            // 실전 모의고사 영역에 정보 표시
    
    
    // login 상태가 아닌 경우
        // 2번 api 를 통해 전체 정보를 fetch
        // 실전 모의고사 section 에 정보를 표시
            // cell.configure(DTO)
    
    
}
