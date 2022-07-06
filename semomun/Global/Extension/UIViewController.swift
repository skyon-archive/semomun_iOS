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
            self?.showLoginVC()
        }
        
        alert.addAction(cancel)
        alert.addAction(login)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoginVC() {
        let startLoginVC = UIStoryboard(name: LoginStartVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginStartVC.identifier) 
        let navigationVC = UINavigationController(rootViewController: startLoginVC)
        navigationVC.navigationBar.tintColor = UIColor(.blueRegular)
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
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        }
        alert.addAction(ok)
        self.present(alert, animated: true)
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
    
    func setShadow(with view: UIView) {
        view.layer.shadowOpacity = 0.25
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 4.5
    }
    
    func showLongTextVC(title: String, txtResourceName: String, marketingInfo: Bool = false, isPopup: Bool = false) {
        guard let filepath = Bundle.main.path(forResource: txtResourceName, ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.showLongTextVC(title: title, text: text, marketingInfo: marketingInfo, isPopup: isPopup)
        } catch {
            self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    func showLongTextVC(title: String, text: String, marketingInfo: Bool = false, isPopup: Bool = false) {
        let storyboard = UIStoryboard(controllerType: LongTextVC.self)
        guard let vc = storyboard.instantiateViewController(withIdentifier: LongTextVC.identifier) as? LongTextVC else { return }
        vc.configureUI(navigationBarTitle: title, text: text, isPopup: isPopup, marketingInfo: marketingInfo)
        if isPopup {
            let navigationView = UINavigationController(rootViewController: vc)
            self.present(navigationView, animated: true)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addPageSwipeGesture() {
        let rightSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightDragged))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(rightSwipeGesture)
        
        let leftSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftDragged))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(leftSwipeGesture)
    }
    
    @objc func rightDragged() {
        NotificationCenter.default.post(name: .previousPage, object: nil)
    }
    
    @objc func leftDragged() {
        NotificationCenter.default.post(name: .nextPage, object: nil)
    }
}


