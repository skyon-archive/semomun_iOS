//
//  Preview_Core+CoreDataProperties.swift
//  Preview_Core
//
//  Created by qwer on 2021/09/15.
//
//

import Foundation
import CoreData

extension Preview_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preview_Core> {
        return NSFetchRequest<Preview_Core>(entityName: "Preview_Core")
    }
    
    @NSManaged public var wid: Int64
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var subject: String?
    @NSManaged public var sids: [Int]
}

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
    
    public override var description: String{
        return "Preview(\(self.wid), \(self.image), \(self.title), \(self.subject), \(self.sids)"
    }
    // functions to replace the custom initialization methods
    func setValues(preview: PreviewOfDB, subject: String, sids: [Int]){
        self.setValue(Int64(preview.wid), forKey: "wid")
        self.setValue(preview.title, forKey: "title")
        self.setValue(Data(), forKey: "image")
        self.setValue(subject, forKey: "subject")
        self.setValue(sids, forKey: "sids")
    }
}
