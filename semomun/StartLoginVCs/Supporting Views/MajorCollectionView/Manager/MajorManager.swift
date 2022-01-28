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
    
    func updateItems(with majors: [Major]) {
        self.items = majors.map(\.name)
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
