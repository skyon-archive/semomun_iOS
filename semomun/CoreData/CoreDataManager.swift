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
    static let saveErrorNotificationName = Notification.Name("refresh")
    
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    /// - Warning: DispatchQueue로 이 함수를 호출하지 말고, saveCoreDataConcurrently()를 사용.
    ///
    /// 이 [튜토리얼](https://cocoacasts.com/core-data-and-concurrency/)과 이 [애플 문서](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Concurrency.html)를 참고
    static func saveCoreData() {
        DispatchQueue.main.async {
            do { try CoreDataManager.shared.context.save() } catch let error {
                print("CoreData 저장 에러 \(error.localizedDescription)")
                NotificationCenter.default.post(name: saveErrorNotificationName, object: nil, userInfo: ["errorMessage": error.localizedDescription])
            }
        }
    }
    
}
