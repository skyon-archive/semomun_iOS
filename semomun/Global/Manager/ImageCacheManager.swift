//
//  ImageCache.swift
//  semomun
//
//  Created by Kang Minsang on 2022/04/05.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func getImage(uuid: UUID) -> UIImage? {
        let cachedKey = NSString(string: uuid.uuidString.lowercased())
        return self.cache.object(forKey: cachedKey)
    }
    
    func saveImage(uuid: UUID, image: UIImage) {
        let cachedKey = NSString(string: uuid.uuidString.lowercased())
        self.cache.setObject(image, forKey: cachedKey)
        print("Save cache image: \(uuid.uuidString.lowercased())")
    }
}
