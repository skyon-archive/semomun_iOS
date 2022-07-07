//
//  WorkbookGroup_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/22.
//
//
import Foundation
import CoreData

@objc(WorkbookGroup_Core)
public class WorkbookGroup_Core: NSManagedObject {
    public override var description: String {
        return "WorkbookGroup(\(self.wgid))"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkbookGroup_Core> {
        return NSFetchRequest<WorkbookGroup_Core>(entityName: "WorkbookGroup_Core")
    }
    
    var info: WorkbookGroupInfo {
        return WorkbookGroupInfo(wgid: Int(self.wgid), title: self.title ?? "")
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
        case progressCount
    }

    @NSManaged public var wgid: Int64
    @NSManaged public var productID: Int64
    @NSManaged public var type: String? // 실전 모의고사 등 WorkbookGroup 의 분기를 위한 값
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var purchasedDate: Date?
    @NSManaged public var recentDate: Date?
    @NSManaged public var wids: [Int]
    @NSManaged public var progressCount: Int64 // 진도율 계산을 위한 푼 workbook 수
    
    func setValues(workbookGroup: WorkbookGroupOfDB, purchasedInfo: PurchasedWorkbookGroupInfoOfDB) {
        self.setValue(Int64(workbookGroup.wgid), forKey: Attribute.wgid.rawValue)
        self.setValue(Int64(workbookGroup.productID ?? -1), forKey: Attribute.productID.rawValue)
        self.setValue(workbookGroup.type, forKey: Attribute.type.rawValue)
        self.setValue(workbookGroup.title, forKey: Attribute.title.rawValue)
        self.setValue(workbookGroup.detail, forKey: Attribute.detail.rawValue)
        self.setValue(purchasedInfo.purchasedDate, forKey: Attribute.purchasedDate.rawValue)
        self.setValue(purchasedInfo.recentDate, forKey: Attribute.recentDate.rawValue)
        self.setValue(purchasedInfo.wids, forKey: Attribute.wids.rawValue)
        self.setValue(0, forKey: Attribute.progressCount.rawValue)
    }
    
    func fetchGroupcover(uuid: UUID, networkUsecase: S3ImageFetchable?, completion: @escaping (() -> Void)) {
        networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover) { [weak self] status, data in
            guard status == .SUCCESS, let data = data else {
                print("Error: fetchGroupcover")
                completion()
                return
            }
            self?.setValue(data, forKey: Attribute.image.rawValue)
            completion()
        }
    }
    
    func updateInfos(purchasedInfo: PurchasedWorkbookGroupInfoOfDB) {
        self.setValue(purchasedInfo.purchasedDate, forKey: Attribute.purchasedDate.rawValue)
        self.setValue(purchasedInfo.recentDate, forKey: Attribute.recentDate.rawValue)
        self.setValue(purchasedInfo.wids, forKey: Attribute.wids.rawValue)
    }
    
    func updateProgress() {
        let count = min(Int(self.progressCount)+1, self.wids.count)
        self.setValue(count, forKey: Attribute.progressCount.rawValue)
    }
    
    var cellInfo: WorkbookGroupCellInfo {
        return WorkbookGroupCellInfo(core: self)
    }
}
