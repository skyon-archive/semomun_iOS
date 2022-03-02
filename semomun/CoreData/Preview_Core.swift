//
//  Preview_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/15.
//
//

import Foundation
import CoreData
import UIKit

extension Preview_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preview_Core> {
        return NSFetchRequest<Preview_Core>(entityName: "Preview_Core")
    }
    
    enum Attribute: String {
        case id
        case wid
        case title
        case detail
        case isbn
        case author
        case publisher
        case date
        case publishMan
        case originalPrice
        case updatedAt
        case sids
        case price
        case tags
        case size
        case image
    }
    
    @NSManaged public var id: Int64 // NEW: 상품 식별자
    @NSManaged public var wid: Int64 // identifier
    @NSManaged public var title: String?
    @NSManaged public var detail: String? // 문제집 정보
    @NSManaged public var isbn: String? // NEW: ISBN값
    @NSManaged public var author: String? // NEW: 저자
    @NSManaged public var publisher: String? // 출판사 (publishCompany)
    @NSManaged public var date: Date? // NEW: 발행일
    @NSManaged public var publishMan: String? // NEW: 발행인
    @NSManaged public var originalPrice: String? // NEW: 정가
    @NSManaged public var updatedAt: Date? // NEW: 반영일자
    @NSManaged public var sids: [Int] // Sections id
    @NSManaged public var price: Double // 가격
    @NSManaged public var tags: [String]
    @NSManaged public var size: Int64 // NEW: sections size 합산
    @NSManaged public var image: Data? // Workbook Image
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var subject: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var category: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var year: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var month: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var terminated: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var downloaded: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var grade: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isHide: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isReproduction: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isNotFree: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var maxCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var largeLargeCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var largeCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var mediumCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var smallCategory: String? //Deprecated(1.1.3)
    
}

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
    
    public override var description: String {
        return "Preview(\(self.wid), \(self.image!), \(self.title!), \(self.subject!), \(self.sids), \(self.terminated), \(self.category!), \(self.downloaded)\n"
    }
    
    func setValues(preview: PreviewOfDB, workbook: PreviewOfDB, sids: [Int], baseURL: String, category: String) {
        self.setValue(Int64(preview.wid), forKey: "wid")
        self.setValue(preview.title, forKey: "title")
        self.setValue(sids, forKey: "sids")
        self.setValue(Double(workbook.originalPrice), forKey: "price")
        self.setValue(workbook.detail, forKey: "detail")
        self.setValue(workbook.publishCompany, forKey: "publisher")
        self.setValue([], forKey: "tags") // default
        
        if let url = URL(string: baseURL + preview.bookcover) {
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                self.setValue(imageData, forKey: "image")
            } else {
                self.setValue(UIImage(.warning).pngData(), forKey: "image")
            }
        } else {
            self.setValue(UIImage(.warning).pngData(), forKey: "image")
        }
        print("savePreview complete")
    }
    
    func setValues(workbook: WorkbookOfDB, bookcoverData: Data) {
        self.setValue(Int64(workbook.productID), forKey: Attribute.id.rawValue)
        self.setValue(Int64(workbook.wid), forKey: Attribute.wid.rawValue)
        self.setValue(workbook.title, forKey: Attribute.title.rawValue)
        self.setValue(workbook.detail, forKey: Attribute.detail.rawValue)
        self.setValue(workbook.isbn, forKey: Attribute.isbn.rawValue)
        self.setValue(workbook.author, forKey: Attribute.author.rawValue)
        self.setValue(workbook.publishCompany, forKey: Attribute.publisher.rawValue)
        self.setValue(workbook.publishdDate, forKey: Attribute.date.rawValue)
        self.setValue(workbook.publishMan, forKey: Attribute.publishMan.rawValue)
        self.setValue(workbook.originalPrice, forKey: Attribute.originalPrice.rawValue)
        self.setValue(workbook.updatedDate, forKey: Attribute.updatedAt.rawValue)
        self.setValue(workbook.sections.map(\.sid), forKey: Attribute.sids.rawValue)
        self.setValue(Double(workbook.price), forKey: Attribute.price.rawValue)
        self.setValue(workbook.tags.map(\.name), forKey: Attribute.tags.rawValue)
        self.setValue(Int64(workbook.sections.reduce(0, { $0 + $1.fileSize})), forKey: Attribute.size.rawValue)
        self.setValue(bookcoverData, forKey: Attribute.image.rawValue)
        print("savePreview complete")
    }
}
