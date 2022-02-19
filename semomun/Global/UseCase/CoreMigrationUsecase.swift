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
        if CoreUsecase.updateSectionHeaders() == false {
            completion(false)
            return
        }
        
        if CoreUsecase.updateSections() == false {
            completion(false)
            return
        }
        completion(true)
    }
    
    static func updateSectionHeaders() -> Bool {
        // fetch all previews
        guard let previews = CoreUsecase.fetchPreviews() else { return false }
        // previews.forEach
        for preview in previews {
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
                        sectionHeader.setValue(true, forKey: "terminated")
                    }
                }
            }
        }
        print("PREVIEW MIGRATION SUCCESS")
        return true
    }
    
    static func updateSections() -> Bool {
        // fetch all sections
        guard let sections = CoreUsecase.fetchSections() else { return false }
        // sections.forEach
        for section in sections {
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
            }
        }
        print("SECTION MIGRATION SUCCESS")
        return true
    }
    
    static func getPageCores(pNames: [String], dictionary: [String: Int]) -> [Page_Core] {
        let vids = NSOrderedSet(array: pNames.map { dictionary[$0, default: 0] }).map { $0 as? Int ?? 0 }
        let pageCores = vids.map { vid in CoreUsecase.fetchPage(vid: vid) }.compactMap { $0 }
        return pageCores
    }
    
    static func getProblemCores(pageCores: [Page_Core]) -> [Problem_Core] {
        let problemCores = pageCores.map { page in page.problems.map { pid in CoreUsecase.fetchProblem(pid: pid) }.compactMap { $0 } }.reduce([], +)
        return problemCores
    }
}
