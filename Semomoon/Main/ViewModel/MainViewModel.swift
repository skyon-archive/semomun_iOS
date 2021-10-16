//
//  MainViewModel.swift
//  Semomoon
//
//  Created by qwer on 2021/10/16.
//

import Foundation

protocol MainActions: AnyObject {
    
}

class MainViewModel {
    weak var delegate: MainActions!
    
    init(delegate: MainActions) {
        self.delegate = delegate
    }
}
