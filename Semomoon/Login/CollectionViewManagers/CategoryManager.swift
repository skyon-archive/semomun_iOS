//
//  CategoryManager.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/11/28.
//

import Foundation

final class CategoryManager {
    private var items: [String] = []
    private(set) var selectedIndex: Int?
    
    func fetch(completion: @escaping(() -> Void)) {
        // TODO: 추후 DB 에서 수신하는 것으로 수정 예정
        self.items = ["수능 및 모의고사", "LEET", "공인회계사", "공인중개사", "9급 공무원"]
        completion()
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
