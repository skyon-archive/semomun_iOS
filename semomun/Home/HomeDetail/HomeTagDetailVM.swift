//
//  HomeTagDetailVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/12.
//

import Foundation

final class HomeTagDetailVM: HomeDetailVM<WorkbookPreviewOfDB> {
    @Published private(set) var currentTagList: [String] = []
}
