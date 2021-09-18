//
//  Preview_Core+CoreDataClass.swift
//  Preview_Core
//
//  Created by qwer on 2021/09/15.
//
//

import Foundation
import CoreData

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
//    @NSManaged public var wid: Int64
//    @NSManaged public var image: Data?
//    @NSManaged public var title: String?
//    @NSManaged public var subject: String?
    
    public override var description: String{
        return "Preview of \(self.title!), wid is \(self.wid)"
    }
    
    // functions to replace the custom initialization methods
    func preview2core(preview: Preview){
        self.setValue(Int64(preview.wid), forKey: "wid")
        self.setValue(preview.title, forKey: "title")
        self.setValue(preview.image, forKey: "image")
        self.setValue(nil, forKey: "subject")
    }
    
    func addSubject(subject: String) {
        self.setValue(subject, forKey: "subject")
    }
}
