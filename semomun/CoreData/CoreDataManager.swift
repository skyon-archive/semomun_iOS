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
        do { try shared.context.save() } catch let error {
            print("CoreData 에러: \(error.localizedDescription)")
        }
    }
}
