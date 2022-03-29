//
//  UIStoryboard.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

extension UIStoryboard {
    static func controlledDevice(vcType: StoryboardController.Type) -> UIStoryboard {
        return UIStoryboard(name: vcType.storyboardName, bundle: nil)
    }
}
