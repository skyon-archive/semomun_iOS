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
        if CoreUsecase.updateSections() == false {
            completion(false)
            return
        }
        
        CoreUsecase.updateSectionHeaders() { success in
            guard success else {
                completion(false)
                return
            }
            
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
            UserDefaultsManager.coreVersion = version
            CoreDataManager.saveCoreData()
            completion(true)
            return
        }
    }
    
    static func updateSectionHeaders(completion: @escaping (Bool) -> Void) {
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
    
    static func updateSections() -> Bool {
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
    
    static func getPageCores(pNames: [String], dictionary: [String: Int]) -> [Page_Core] {
        let vids = NSOrderedSet(array: pNames.map { dictionary[$0, default: 0] }).map { $0 as? Int ?? 0 }
        let pageCores = vids.compactMap { vid in CoreUsecase.fetchPage(vid: vid) }
        return pageCores
    }
    
    static func getProblemCores(pageCores: [Page_Core]) -> [Problem_Core] {
        let problemCores = pageCores.flatMap { page in
            page.problems.compactMap { pid in
                CoreUsecase.fetchProblem(pid: pid)
            }
        }
        return problemCores
    }
}
