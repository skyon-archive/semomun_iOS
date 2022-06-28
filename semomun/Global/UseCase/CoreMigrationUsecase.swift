//
//  CoreMigrationUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import Foundation
import CoreData

extension CoreUsecase {
    static func migration(completion: @escaping(Bool) -> Void) {
        /// Problem - Page - Section 간의 구조를 맞추는 로직
        if CoreUsecase.updateSections() == false {
            completion(false)
            return
        }
        /// sectionHeader 반영 및 workbook들 구매 반영 로직
        CoreUsecase.updateSectionHeadersAndPostPurchase() { success in
            guard success else {
                completion(false)
                return
            }
            /// 성공시 동작 로직
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
            UserDefaultsManager.coreVersion = version
            CoreDataManager.saveCoreData()
            /// 기존 Workbook 들의 정보를 최신화 하는 로직
            self.updateAllWorkbooks { success in
                completion(success)
                return
            }
        }
    }
    
    private static func updateSectionHeadersAndPostPurchase(completion: @escaping (Bool) -> Void) {
        // fetch all previews
        guard let previews = CoreUsecase.fetchPreviews() else {
            completion(false)
            return
        }
        let networkUsecase: (WorkbookSearchable & UserPurchaseable) = NetworkUsecase(network: Network())
        let purchaseCount: Int = previews.count
        var productIds: [Int] = []
        
        if previews.isEmpty {
            completion(true)
        }
        
        // previews.forEach
        for preview in previews {
            preview.setValue(0, forKey: Preview_Core.Attribute.progressCount.rawValue)
            // fetch sectionHeaders
            guard let sectionHeaders = CoreUsecase.fetchSectionHeaders(wid: Int(preview.wid)) else { continue }
            let sectionCount = sectionHeaders.count
            sectionHeaders.forEach { sectionHeader in
                if sectionCount == 1 {
                    // update sectionHeader: downloaded
                    if preview.downloaded {
                        sectionHeader.setValue(true, forKey: "downloaded")
                    }
                    // update sectionHeader: terminated
                    if preview.terminated {
                        preview.updateProgress()
                        sectionHeader.setValue(true, forKey: "terminated")
                    }
                }
            }
            // fetch productID -> append productID
            networkUsecase.getWorkbook(wid: Int(preview.wid)) { workbook in
                guard let workbook = workbook else {
                    completion(false)
                    return
                }

                productIds.append(workbook.productID)
                // POST /pay/orders 반영
                if productIds.count == purchaseCount {
                    networkUsecase.purchaseItem(productIDs: productIds) { status, credit in
                        print("PURCHASES MIGRATION SUCCESS")
                        completion(status == .SUCCESS)
                    }
                }
            }
        }
        print("PREVIEW MIGRATION SUCCESS")
    }
    
    private static func updateSections() -> Bool {
        // fetch all sections
        guard let sections = CoreUsecase.fetchSections() else { return false }
        
        // sections.forEach
        for section in sections {
            // 기존 풀이내역 및 지문필기를 upload 하기 위한 queue 생성
            var scoringQueue: [Int] = []
            var uploadProblemsQueue: [Int] = []
            var uploadPagesQueue: [Int] = []
            // get pages
            let pageCores = CoreUsecase.getPageCores(pNames: section.buttons, dictionary: section.dictionaryOfProblem)
            // get problems
            let problemCores = CoreUsecase.getProblemCores(pageCores: pageCores)
            
            // pNames.forEach
            for (idx, pName) in section.buttons.enumerated() {
                // find page from dictionary[pName]
                guard let page = pageCores.first(where: { $0.vid == section.dictionaryOfProblem[pName] ?? 0 }) else {
                    print("ERROR: CAN'T FIND PAGE: \(section.dictionaryOfProblem[pName] ?? 0)")
                    continue
                }
                // find problem from pName
                guard let problem = problemCores.first(where: { $0.pName == pName }) else {
                    print("ERROR: CAN'T FIND PROBLEM: \(pName)")
                    continue
                }
                
                // update Problem
                problem.setValue(idx, forKey: "orderIndex")
                problem.pageCore = page
                problem.sectionCore = section
                // update queue
                if problem.solved != nil && scoringQueue.contains(Int(problem.pid)) == false {
                    scoringQueue.append(Int(problem.pid))
                }
                if problem.drawing != nil && uploadProblemsQueue.contains(Int(problem.pid)) == false {
                    uploadProblemsQueue.append(Int(problem.pid))
                }
                if page.drawing != nil && uploadPagesQueue.contains(Int(page.vid)) == false {
                    uploadPagesQueue.append(Int(page.vid))
                }
            }
            
            // save queue
            if scoringQueue.isEmpty == false {
                section.setValue(scoringQueue, forKey: Section_Core.Attribute.scoringQueue.rawValue)
            }
            if uploadProblemsQueue.isEmpty == false {
                section.setValue(uploadProblemsQueue, forKey: Section_Core.Attribute.uploadProblemQueue.rawValue)
            }
            if uploadPagesQueue.isEmpty == false {
                section.setValue(uploadPagesQueue, forKey: Section_Core.Attribute.uploadPageQueue.rawValue)
            }
        }
        print("SECTION MIGRATION SUCCESS")
        return true
    }
    
    private static func getPageCores(pNames: [String], dictionary: [String: Int]) -> [Page_Core] {
        let vids = NSOrderedSet(array: pNames.compactMap { dictionary[$0] }).compactMap { $0 as? Int }
        let pageCores = vids.compactMap { vid in CoreUsecase.fetchPage(vid: vid) }
        return pageCores
    }
    
    private static func getProblemCores(pageCores: [Page_Core]) -> [Problem_Core] {
        let problemCores = pageCores.flatMap { page in
            page.problems.compactMap { pid in
                CoreUsecase.fetchProblem(pid: pid)
            }
        }
        return problemCores
    }
    
    private static func updateAllWorkbooks(completion: @escaping (Bool) -> Void) {
        let networkUsecase: (UserWorkbooksFetchable & WorkbookSearchable & S3ImageFetchable) = NetworkUsecase(network: Network())
        networkUsecase.getUserBookshelfInfos { status, infos in
            guard status == .SUCCESS,
                  let previews = self.fetchPreviews() else {
                completion(false)
                return
            }
            guard infos.isEmpty == false else {
                completion(true)
                return
            }
            
            print("update All Workbooks")
            let userPurchases = infos.map { BookshelfInfo(info: $0) }
            let taskGroup = DispatchGroup()
            
            userPurchases.forEach { info in
                taskGroup.enter()
                networkUsecase.getWorkbook(wid: info.wid) { workbook in
                    guard let workbook = workbook else {
                        taskGroup.leave()
                        completion(false)
                        return
                    }

                    /// 개발진행자의 경우 Coredata 상에 없는 구매한 workbook이 존재
                    /// 일반 사용자의 경우 아이폰용이 출시되기전까지 진행되지 않는다
                    guard let preview_core = (previews.first { $0.wid == Int64(info.wid) }) else {
                        print("CoreData 상에 없는 Workbook")
                        taskGroup.leave()
                        return
                    }
                    
                    preview_core.setValues(workbook: workbook, info: info)
                    preview_core.fetchBookcover(uuid: workbook.bookcover, networkUsecase: networkUsecase, completion: {
                        print("update preview(\(info.wid) complete")
                        taskGroup.leave()
                    })
                }
            }
            
            taskGroup.notify(queue: .main) {
                CoreDataManager.saveCoreData()
                print("update All Workbooks Success")
                completion(true)
                return
            }
        }
    }
}
