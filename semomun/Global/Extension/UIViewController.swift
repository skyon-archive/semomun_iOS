//
//  UIViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/30.
//

import UIKit
import CoreData

extension UIViewController {
    
    func showLoginAlert() {
        let alert = UIAlertController(title: "로그인이 필요한 서비스입니다", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let login = UIAlertAction(title: "로그인하기", style: .default) { [weak self] _ in
            self?.showLoginViewController()
        }
        
        alert.addAction(cancel)
        alert.addAction(login)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoginViewController() {
        guard let startLoginVC = self.storyboard?.instantiateViewController(withIdentifier: StartLoginViewController.identifier) else { return }
        let navigationVC = UINavigationController(rootViewController: startLoginVC)
        navigationVC.navigationBar.tintColor = UIColor(named: SemomunColor.mainColor)
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func showAlertWithCancelAndOK(title: String, text: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        let ok = UIAlertAction(title: "확인", style: .destructive, handler:  { _ in
            completion()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func showAlertWithOK(title: String, text: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion?()
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
    
    func startLoading(count: Int = 0) -> LoadingDelegate {
        let loadingIndicator = self.storyboard?.instantiateViewController(withIdentifier: LoadingIndicator.identifier) as! LoadingIndicator
        loadingIndicator.loadViewIfNeeded()
        loadingIndicator.totalPageCount = count
        self.present(loadingIndicator, animated: true, completion: nil)
        return loadingIndicator as LoadingDelegate
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
        NotificationCenter.default.addObserver(forName: CoreDataManager.saveErrorNotificationName, object: nil, queue: .main) { [weak self] noti in
            guard let errorMessage = noti.userInfo?["errorMessage"] as? String else { return }
            self?.showAlertWithOK(title: "데이터 저장 실패", text: errorMessage)
        }
    }
}
