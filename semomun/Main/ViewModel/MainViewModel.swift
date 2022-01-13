//
//  MainViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

class MainViewModel {
    let useCase: MainLogic
    init(useCase: MainLogic) {
        self.useCase = useCase
    }
}
