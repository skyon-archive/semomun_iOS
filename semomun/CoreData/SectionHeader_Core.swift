//
//  SectionHeader_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData
import UIKit

extension SectionHeader_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionHeader_Core> {
        return NSFetchRequest<SectionHeader_Core>(entityName: "SectionHeader_Core")
    }
    
    @NSManaged public var sid: Int64
    @NSManaged public var wid: Int64
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var cutoff: String?
    @NSManaged public var downloaded: Bool
    @NSManaged public var terminated: Bool
}

@objc(SectionHeader_Core)
public class SectionHeader_Core: NSManagedObject {
    public override var description: String {
        return "SectionHeader(\(self.sid), \(optional: self.title), \(optional: self.image))"
    }
    // functions to replace the custom initialization methods
    func setValues(section: SectionOfDB, baseURL: String, wid: Int) {
        self.setValue(Int64(section.sid), forKey: "sid")
        self.setValue(Int64(wid), forKey: "wid")
        self.setValue(section.title, forKey: "title")
        self.setValue(section.detail, forKey: "detail")
        self.setValue(section.cutoff, forKey: "cutoff")
        self.setValue(false, forKey: "downloaded")
        self.setValue(false, forKey: "terminated")
        self.setValue(nil, forKey: "image")
//        if let url = URL(string: baseURL + section.image) {
//            let imageData = try? Data(contentsOf: url)
//            if imageData != nil {
//                self.setValue(imageData, forKey: "image")
//            } else {
//                self.setValue(UIImage(named: SemomunImage.warning)!.pngData(), forKey: "image")
//            }
//        } else {
//            self.setValue(UIImage(named: SemomunImage.warning)!.pngData(), forKey: "image")
//        }
        print("save Header complete")
    }
}

extension SectionHeader_Core : Identifiable {
}
