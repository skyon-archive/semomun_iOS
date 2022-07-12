//
//  HomeBookcoverConfigurable.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import Foundation

protocol HomeBookcoverConfigurable {
    var title: String { get }
    var publishCompany: String { get }
    var bookcover: UUID { get }
}
