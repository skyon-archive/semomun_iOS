//
//  PreviewManager.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

class SearchWorkbookManager {
    let filter: [Int]
    var loadedPreviews: [PreviewOfDB] = []
    var queryDic: [String: String?] = ["s": nil, "g": nil, "y": nil, "m": nil]
    var imageScale: NetworkUsecase.scale = .large
    
    init(filter: [Preview_Core]) {
        self.filter = filter.map { Int($0.wid) }
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
        let url = NetworkUsecase.URL.bookcovoerImageDirectory(imageScale) + preview(at: at).image
        return url
    }
    
    func queryStringOfPreviews() -> [String: String] {
        var queryItems: [String: String] = [:]
        self.queryDic.forEach {
            if($0.value != nil) { queryItems[$0.key] = $0.value }
        }
        return queryItems
    }
    
    func loadPreviews(completion: @escaping ()->Void) {
        NetworkUsecase.downloadPreviews(param: queryStringOfPreviews()) { searchPreview in
            let previews = searchPreview.workbooks
            self.loadedPreviews = previews.filter { !self.filter.contains($0.wid) }
            completion()
        }
    }
}
