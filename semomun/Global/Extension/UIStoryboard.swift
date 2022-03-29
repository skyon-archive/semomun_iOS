//
//  UIStoryboard.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

extension UIStoryboard {
    static func makeVCForCurrentUI(_ storyboardOriginVC: StoryboardController.Type) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardOriginVC.storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardOriginVC.identifier)
        return vc
    }
}
