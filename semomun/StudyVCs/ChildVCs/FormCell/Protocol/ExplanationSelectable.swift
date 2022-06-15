//
//  ExplanationSelectable.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/15.
//

import UIKit

protocol ExplanationSelectable: AnyObject {
    func selectExplanation(image: UIImage?, pid: Int)
}
