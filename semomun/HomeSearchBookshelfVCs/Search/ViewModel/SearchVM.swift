//
//  SearchVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import Foundation
import Combine

final class SearchVM {
    @Published private(set) var tags: [String] = []
    
    func tag(index: Int) -> String {
        return self.tags[index]
    }
    
    func append(tag: String) {
        self.tags.append(tag)
    }
    
    func removeTag(index: Int) {
        self.tags.remove(at: index)
    }
    
    func removeAll() {
        self.tags.removeAll()
    }
}
