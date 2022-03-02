//
//  SearchWorkbookManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

class SearchWorkbookManager {
    private let filter: [Int]
    var loadedPreviews: [PreviewOfDB] = []
    var queryDic: [String: String?] = ["s": nil, "g": nil, "y": nil, "m": nil]
    var imageScale: NetworkURL.scale = .large
    var category: String
    private(set) var selectedIndex: Int?
    private let networkUseCase: NetworkUsecase
    
    init(filter: [Preview_Core], category: String, networkUseCase: NetworkUsecase) {
        self.filter = filter.map { Int($0.wid) }
        self.category = category
        self.networkUseCase = networkUseCase
        self.queryDic["c"] = category
    }
    
    func select(to index: Int) {
        self.selectedIndex = index
    }
    
    var count: Int {
        return loadedPreviews.count
    }
    
    func title(at: Int) -> String {
        return loadedPreviews[at].title
    }
    
    func preview(at: Int) -> PreviewOfDB {
        return loadedPreviews[at]
    }
    
    func imageURL(at: Int) -> String {
        let url = NetworkURL.bookcoverImageDirectory(imageScale) + preview(at: at).bookcover
        return url
    }
    
    private var queryStringOfPreviews: [String: String] {
        var queryItems: [String: String] = [:]
        self.queryDic.forEach {
            if($0.value != nil) { queryItems[$0.key] = $0.value }
        }
        return queryItems
    }
    
    func loadPreviews(completion: @escaping ()->Void) {
        self.networkUseCase.downloadPreviews(param: self.queryStringOfPreviews) { searchPreview in
            let previews = searchPreview.previews
            self.loadedPreviews = previews.filter { !self.filter.contains($0.wid) }
            completion()
        }
    }
}
