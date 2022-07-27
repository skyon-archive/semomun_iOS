//
//  SolvedUpdateable.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import Foundation

protocol SolvedUpdateable: AnyObject {
    func updateSolved(answer: String, problem: Problem_Core)
}
