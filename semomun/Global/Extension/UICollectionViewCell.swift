//
//  UICollectionViewCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/06.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    func saveCoreData() {
        do { try CoreDataManager.shared.context.save() } catch let error {
            print(error.localizedDescription)
        }
    }
}
