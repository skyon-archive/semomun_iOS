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
        // fetch all previews
        guard let previews = CoreUsecase.fetchPreviews() else {
            completion(false)
            return
        }
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
        CoreDataManager.saveCoreData()
        // fetch all sections
        guard let sections = CoreUsecase.fetchSections() else {
            completion(false)
            return
        }
        // sections.forEach
        for section in sections {
            // get vids
            let vids = NSOrderedSet(array:
                                        section.buttons.map { section.dictionaryOfProblem[$0, default: 0] })
                .map { $0 as? Int ?? 0 }
            // get problems
            let problems =  vids.map() { vid in
                CoreUsecase.fetchPage(vid: vid)
            }.compactMap({$0}).map() { page in
                page.problems.map() { pid in
                    CoreUsecase.fetchProblem(pid: pid)
                }.compactMap({$0})
            }.reduce([], +)
            
        }
        print("SECTION MIGRATION SUCCESS")
        CoreDataManager.saveCoreData()
        completion(true)
    }
}
