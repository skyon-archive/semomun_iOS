//
//  MainUseCase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

typealias MainFetchables = (PagesFetchable & VersionFetchable)
protocol MainLogic {
}

class MainUseCase: MainLogic {
    let networkUseCase: MainFetchables
    init(networkUseCase: MainFetchables) {
        self.networkUseCase = networkUseCase
    }
}
