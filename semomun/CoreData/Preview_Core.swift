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
    
    @NSManaged public var wid: Int64 // Workbook id
    @NSManaged public var image: Data? // Workbook Image
    @NSManaged public var title: String? // Workbook title
    @NSManaged public var sids: [Int] // Sections id
    @NSManaged public var price: Double // 가격
    @NSManaged public var detail: String? // 문제집 정보
    @NSManaged public var publisher: String? // 출판사
    @NSManaged public var tags: [String] // 중분류
    
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
    
    func setValues(preview: PreviewOfDB, workbook: WorkbookOfDB, sids: [Int], baseURL: String, category: String) {
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
    
    func setValues(searchWorkbook: SearchWorkbook) {
        let workbook = searchWorkbook.workbook
        self.setValue(Int64(workbook.wid), forKey: "wid")
        self.setValue(workbook.title, forKey: "title")
        self.setValue(searchWorkbook.sections.map(\.sid), forKey: "sids")
        self.setValue(Double(workbook.originalPrice), forKey: "price")
        self.setValue(workbook.detail, forKey: "detail")
        self.setValue(workbook.publishCompany, forKey: "publisher")
        self.setValue([], forKey: "tags")
        
        if let url = URL(string: NetworkURL.bookcoverImageDirectory(.large) + workbook.bookcover) {
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
}
