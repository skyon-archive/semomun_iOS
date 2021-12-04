//
//  PreviewManager.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

class SearchWorkbookManager {
    var loadedPreviews: [PreviewOfDB] = []
    var queryDic: [String: String?] = ["s": nil, "g": nil, "y": nil, "m": nil]
    var imageScale: NetworkUsecase.scale = .large
    
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
}
