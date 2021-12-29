//
//  UIViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/30.
//

import UIKit
import CoreData

extension UIViewController {
    
    func showAlertWithOK(title: String, text: String) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func showAlertWithClosure(title: String, text: String, completion: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        let ok = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion(true)
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func showAlertOKWithClosure(title: String, text: String, completion: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion(true)
        })
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func makeLoaderWithoutPercentage(_ tag: Int = 123) -> UIActivityIndicatorView {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.white
        loader.tag = tag
        return loader
    }
    
    func startLoading(count: Int = 0) -> loadingDelegate {
        let loadingIndicator = self.storyboard?.instantiateViewController(withIdentifier: LoadingIndicator.identifier) as! LoadingIndicator
        loadingIndicator.totalPageCount = count
        self.present(loadingIndicator, animated: true, completion: nil)
        return loadingIndicator as loadingDelegate
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addCoreDataAlertObserver() {
        NotificationCenter.default.addObserver(forName: CoreDataManager.saveErrorNotificationName, object: nil, queue: .main) { noti in
            guard let errorMessage = noti.userInfo?["errorMessage"] as? String else { return }
            self.showAlertWithOK(title: "데이터 저장 실패", text: errorMessage)
        }
    }
}
