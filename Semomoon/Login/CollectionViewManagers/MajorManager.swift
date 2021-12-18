//
//  MajorManager.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/11.
//

import Foundation

final class MajorManager {
    private var items: [String] = []
    private(set) var selectedIndex: Int?
    
    func fetch(completion: @escaping(() -> Void)) {
        // TODO: 추후 DB 에서 수신하는 것으로 수정 예정
        self.items = ["문과 계열", "이과 계열", "예체능 계열"]
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
