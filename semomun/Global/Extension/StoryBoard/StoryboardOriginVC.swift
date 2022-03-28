//
//  StoryboardOriginVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/28.
//

import UIKit

protocol StoryboardOriginVC {
    static var storyboardNames: [UIUserInterfaceIdiom: String] { get }
    static var vcIdentifier: String { get }
}

extension StoryboardOriginVC {
    static var currentUIStoryboardName: String? {
        let currentUI = UIDevice.current.userInterfaceIdiom
        return Self.storyboardNames[currentUI]
    }
}
