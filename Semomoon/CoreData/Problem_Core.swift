//
//  Problem_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData

extension Problem_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Problem_Core> {
        return NSFetchRequest<Problem_Core>(entityName: "Problem_Core")
    }

    @NSManaged public var pid: Int64
    @NSManaged public var contentImage: Data?
    @NSManaged public var time: Int64
    @NSManaged public var answer: String?
    @NSManaged public var solved: String?
    @NSManaged public var correct: Bool
    @NSManaged public var explanationImage: Data?
    @NSManaged public var rate: Int64
    @NSManaged public var drawing: Data?
    @NSManaged public var type: Int64
    @NSManaged public var star: Bool
}

extension Problem_Core : Identifiable {

}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    func updateImage(data: Data?) {
        self.setValue(data, forKey: "contentImage")
    }
}
