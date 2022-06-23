//
//  WorkbookGroup_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/22.
//
//
import Foundation
import CoreData

extension WorkbookGroup_Core {

    
}

@objc(WorkbookGroup_Core)
public class WorkbookGroup_Core: NSManagedObject {
    public override var description: String {
        return "WorkbookGroup(\(self.wgid))"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkbookGroup_Core> {
        return NSFetchRequest<WorkbookGroup_Core>(entityName: "WorkbookGroup_Core")
    }
    
    enum Attribute: String {
        case wgid
        case productID
        case type
        case title
        case detail
        case image
        case purchasedDate
        case recentDate
        case wids
    }

    @NSManaged public var wgid: Int64
    @NSManaged public var productID: Int64
    @NSManaged public var type: String?
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var purchasedDate: Date?
    @NSManaged public var recentDate: Date?
    @NSManaged public var wids: [Int]
    
    func setValues(workbookGroup: WorkbookGroupOfDB) {
        self.setValue(Int64(workbookGroup.wgid), forKey: Attribute.wgid.rawValue)
        self.setValue(Int64(workbookGroup.productID), forKey: Attribute.productID.rawValue)
        self.setValue(workbookGroup.type, forKey: Attribute.type.rawValue)
        self.setValue(workbookGroup.title, forKey: Attribute.title.rawValue)
        self.setValue(workbookGroup.detail, forKey: Attribute.detail.rawValue)
        self.setValue(workbookGroup.createdDate, forKey: Attribute.purchasedDate.rawValue)
    }
}
