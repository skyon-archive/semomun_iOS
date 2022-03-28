//
//  UIStoryboard.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

extension UIStoryboard {
    static func makeVCForCurrentUI(_ storyboardOriginVC: StoryboardOriginVC.Type) -> UIViewController {
        guard let currentUIStoryboardName = storyboardOriginVC.currentUIStoryboardName else {
            assertionFailure()
            return UIViewController()
        }
        let storyboard = UIStoryboard(name: currentUIStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardOriginVC.vcIdentifier)
        return vc
    }
}
