//
//  UINavigationController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/02.
//

import UIKit

extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
