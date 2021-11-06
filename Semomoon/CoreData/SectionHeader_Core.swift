//
//  SectionHeader_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
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
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var cutoff: String?

}

@objc(SectionHeader_Core)
public class SectionHeader_Core: NSManagedObject {
    public override var description: String{
        return "SectionHeader(\(self.sid), \(self.title), \(self.image))\n"
    }
    // functions to replace the custom initialization methods
    func setValues(section: SectionOfDB, baseURL: String) {
        self.setValue(Int64(section.sid), forKey: "sid")
        self.setValue(section.title, forKey: "title")
        self.setValue(section.detail, forKey: "detail")
        self.setValue(nil, forKey: "image")
        self.setValue(section.cutoff, forKey: "cutoff")
        if let url = URL(string: baseURL + section.image) {
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                self.setValue(imageData, forKey: "image")
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "image")
            }
        } else {
            guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
            self.setValue(warningImage.pngData(), forKey: "image")
        }
        print("save Header complete")
    }
}

extension SectionHeader_Core : Identifiable {
}
