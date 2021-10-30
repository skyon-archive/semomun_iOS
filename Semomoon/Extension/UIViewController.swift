//
//  UIViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/10/30.
//

import UIKit
import CoreData

extension UIViewController {
    func saveCoreData() {
        do { try CoreDataManager.shared.context.save() } catch let error {
            print(error.localizedDescription)
        }
    }
}
