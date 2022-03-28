//
//  UIStoryboard.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

extension UIStoryboard {
    static func makeVCForCurrentUI(_ storyboardInitializable: StoryboardOriginVC.Type) -> UIViewController {
        guard let currentUIStoryboardName = storyboardInitializable.currentUIStoryboardName else {
            assertionFailure()
            return UIViewController()
        }
        let storyboard = UIStoryboard(name: currentUIStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardInitializable.vcIdentifier)
        return vc
    }
}
