//
//  CategoryManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/28.
//

import Foundation

final class CategoryManager {
    private var items: [String] = []
    private(set) var selectedIndex: Int?
    let networkUseCase: NetworkUsecase
    init(networkUseCase: NetworkUsecase) {
        self.networkUseCase = networkUseCase
    }
    
    func fetch(completion: @escaping(() -> Void)) {
        self.networkUseCase.getCategorys { categorys in
            guard let categorys = categorys else {
                print("no data")
                return
            }
            self.items = categorys
            UserDefaults.standard.setValue(categorys, forKey: "categorys")
            completion()
        }
    }
    
    var count: Int {
        return items.count
    }
    
    func item(at: Int) -> String {
        return self.items[at]
    }
    
    func selected(to index: Int, completion: @escaping((String) -> Void)) {
        self.selectedIndex = index
        completion(item(at: index))
    }
}
