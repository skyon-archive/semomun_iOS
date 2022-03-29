//
//  UIStoryboard.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

extension UIStoryboard {
    convenience init(controllerType: StoryboardController.Type) {
        self.init(name: controllerType.storyboardName, bundle: nil)
    }
}
