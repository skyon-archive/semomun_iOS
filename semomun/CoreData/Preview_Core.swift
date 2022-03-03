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
        case productID
        case wid
        case title
        case detail
        case isbn
        case author
        case publisher
        case publishedDate
        case publishMan
        case originalPrice
        case updatedDate
        case sids
        case price
        case tags
        case fileSize
        case image
    }
    
    @NSManaged public var productID: Int64 // NEW: 상품 식별자
    @NSManaged public var wid: Int64 // identifier
    @NSManaged public var title: String?
    @NSManaged public var detail: String? // 문제집 정보
    @NSManaged public var isbn: String? // NEW: ISBN값
    @NSManaged public var author: String? // NEW: 저자
    @NSManaged public var publisher: String? // 출판사 (publishCompany)
    @NSManaged public var publishedDate: Date? // NEW: 발행일
    @NSManaged public var publishMan: String? // NEW: 발행인
    @NSManaged public var originalPrice: String? // NEW: 정가
    @NSManaged public var updatedDate: Date? // NEW: 반영일자
    @NSManaged public var sids: [Int] // Sections id
    @NSManaged public var price: Double // 가격
    @NSManaged public var tags: [String]
    @NSManaged public var fileSize: Int64 // NEW: sections size 합산
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
    
    func setValues(workbook: WorkbookOfDB, bookcoverData: Data) {
        self.setValue(Int64(workbook.productID), forKey: Attribute.productID.rawValue)
        self.setValue(Int64(workbook.wid), forKey: Attribute.wid.rawValue)
        self.setValue(workbook.title, forKey: Attribute.title.rawValue)
        self.setValue(workbook.detail, forKey: Attribute.detail.rawValue)
        self.setValue(workbook.isbn, forKey: Attribute.isbn.rawValue)
        self.setValue(workbook.author, forKey: Attribute.author.rawValue)
        self.setValue(workbook.publishCompany, forKey: Attribute.publisher.rawValue)
        self.setValue(workbook.publishedDate, forKey: Attribute.publishedDate.rawValue)
        self.setValue(workbook.publishMan, forKey: Attribute.publishMan.rawValue)
        self.setValue(workbook.originalPrice, forKey: Attribute.originalPrice.rawValue)
        self.setValue(workbook.updatedDate, forKey: Attribute.updatedDate.rawValue)
        self.setValue(workbook.sections.map(\.sid), forKey: Attribute.sids.rawValue)
        self.setValue(Double(workbook.price), forKey: Attribute.price.rawValue)
        self.setValue(workbook.tags.map(\.name), forKey: Attribute.tags.rawValue)
        self.setValue(Int64(workbook.sections.reduce(0, { $0 + $1.fileSize})), forKey: Attribute.fileSize.rawValue)
        self.setValue(bookcoverData, forKey: Attribute.image.rawValue)
        print("savePreview complete")
    }
}
