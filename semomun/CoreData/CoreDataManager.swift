//
//  CoreDataManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/18.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    static func saveCoreData() {
        guard CoreDataManager.shared.context.hasChanges else { return }
        CoreDataManager.shared.context.performAndWait {
            do {
                try CoreDataManager.shared.context.save()
                print("CoreData 저장 success")
            } catch let error {
                print("CoreData 저장 에러 \(error.localizedDescription)")
            }
        }
    }
}
