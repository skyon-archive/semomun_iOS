//
//  MainViewController+Extension.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/16.
//

import UIKit

// MARK: - Sidebar ViewController Configure
extension MainViewController {
    func configureSideBarViewController() {
        // Shadow Background View
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        view.insertSubview(self.sideMenuShadowView, at: 4)
        
        // MARK:- setting sidebar ViewController
        self.sideMenuViewController = storyboard?.instantiateViewController(withIdentifier: SideMenuViewController.identifier) as? SideMenuViewController
        self.sideMenuViewController.defaultHighlightedCell = 0
        self.sideMenuViewController.delegate = self
        
        view.insertSubview(self.sideMenuViewController!.view, at: 5)
        addChild(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParent: self)
        
        // MARK:- setting sidebar autolayout
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false

        self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
        self.sideMenuTrailingConstraint.isActive = true
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func configureShadowTapGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedShadowView))
        self.sideMenuShadowView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTappedShadowView() {
        self.sideMenuState()
    }
    
    func sideMenuState() {
        if !isExpanded {
            self.showSideBar()
        }
        else {
            self.hideSideBar()
        }
    }
    
    func showSideBar() {
        self.animateSideMenu(targetPosition: 0) { _ in
            self.isExpanded = true
        }
        // Animate Shadow (Fade In)
        UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.3 }
    }
    
    func hideSideBar() {
        if self.isExpanded {
            self.animateSideMenu(targetPosition: (-self.sideMenuRevealWidth - self.paddingForRotation)) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}