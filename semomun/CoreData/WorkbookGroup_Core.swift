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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkbookGroup_Core> {
        return NSFetchRequest<WorkbookGroup_Core>(entityName: "WorkbookGroup_Core")
    }

    @NSManaged public var wgid: Int64
    @NSManaged public var productID: Int64
    @NSManaged public var type: String?
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var isGroupOnlyPurchasable: Bool
    @NSManaged public var purchasedDate: Date?
    @NSManaged public var recentDate: Date?
    @NSManaged public var wids: [Int] // workbooks id
}

@objc(WorkbookGroup_Core)
public class WorkbookGroup_Core: NSManagedObject {
    public override var description: String {
        return "WorkbookGroup(\(self.wgid))"
    }
    
    func setValues(workbookGroup: WorkbookGroupOfDB) {
        
    }
}
