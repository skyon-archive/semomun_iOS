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
    
    func showAlertWithOK(title: String, text: String) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func startLoading(count: Int) -> loadingDelegate {
        let loadingIndicator = self.storyboard?.instantiateViewController(withIdentifier: LoadingIndicator.identifier) as! LoadingIndicator
        loadingIndicator.totalPageCount = count
        self.present(loadingIndicator, animated: true, completion: nil)
        return loadingIndicator as loadingDelegate
    }
}
