//
//  MajorManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/11.
//

import Foundation

final class MajorManager {
    private var items: [String] = []
    private(set) var selectedIndex: Int?
    
    func updateItems(with majors: [[String: [String]]]) {
        print(majors)
        self.items = ["문과 계열", "이과 계열", "예체능 계열"]
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
