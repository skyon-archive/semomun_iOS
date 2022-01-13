//
//  MainUseCase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

protocol MainLogic {
    
}

class MainUseCase: MainLogic {
    let networkUseCase: NetworkUsecase
    init(networkUseCase: NetworkUsecase) {
        self.networkUseCase = networkUseCase
    }
}
