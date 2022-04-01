//
//  StoryboardController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

protocol StoryboardController {
    static var identifier: String { get }
    static var storyboardNames: [UIUserInterfaceIdiom: String] { get }
}

extension StoryboardController {
    static var storyboardName: String {
        return Self.storyboardNames[UIDevice.current.userInterfaceIdiom] ?? "Main"
    }
}
