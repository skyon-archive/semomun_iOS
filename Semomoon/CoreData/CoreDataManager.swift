//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by qwer on 2021/09/18.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
}
