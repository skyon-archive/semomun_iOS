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
                // update sectionHeader: downloaded
                if sectionCount == 1 && preview.downloaded {
                    sectionHeader.setValue(true, forKey: "downloaded")
                }
                // update sectionHeader: terminated
                if sectionCount == 1 && preview.terminated {
                    sectionHeader.setValue(true, forKey: "terminated")
                }
            }
        }
        CoreDataManager.saveCoreData()
        completion(true)
    }
}
