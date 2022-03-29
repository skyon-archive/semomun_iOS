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
    static var storyboardName: String { get }
    static var controlledDevice: UIViewController { get }
}

extension StoryboardController {
    static var storyboardName: String {
        return Self.storyboardNames[UIDevice.current.userInterfaceIdiom] ?? "Main"
    }
    
    static var controlledDevice: UIViewController {
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: Self.identifier)
    }
}
