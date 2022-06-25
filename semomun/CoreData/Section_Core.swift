//
//  Section_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData

@objc(Section_Core)
public class Section_Core: NSManagedObject {
    public override var description: String{
        return "Section(\(sid))\n" + (problemCores ?? []).map(\.description).joined(separator: "\n")
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section_Core> {
        return NSFetchRequest<Section_Core>(entityName: "Section_Core")
    }
    
    enum Attribute: String {
        case sid
        case title
        case time
        case lastPageId
        case terminated
        case problemCores
        case scoringQueue
        case uploadProblemQueue
        case uploadPageQueue
        case updatedDate
    }

    @NSManaged public var sid: Int64 //식별 고유값
    @NSManaged public var title: String? //섹션 제목
    @NSManaged public var time: Int64 //누적 시간
    @NSManaged public var lastPageId: Int64 //TODO: lastIndex 수정 예정
    @NSManaged public var terminated: Bool //채점여부
    @NSManaged public var problemCores: [Problem_Core]? //relation으로 생긴 ProblemCore들
    @NSManaged public var scoringQueue: [Int]? //NEW: 부분채점시 표시될 pid들
    @NSManaged public var uploadProblemQueue: [Int]? //NEW: DB상에 upload 될 pid들
    @NSManaged public var uploadPageQueue: [Int]? // NEW: DB상에 upload 될 vid들
    @NSManaged public var updatedDate: Date? // NEW: 반영일자
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var dictionaryOfProblem: [String: Int] //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var buttons: [String] //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var stars: [Bool] //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var wrongs: [Bool] //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var checks: [Bool] //Deprecated(1.1.3)
    
    func setValues(header: SectionHeader_Core) {
        self.setValue(header.sid, forKey: Attribute.sid.rawValue)
        self.setValue(header.title, forKey: Attribute.title.rawValue)
        self.setValue(0, forKey: Attribute.time.rawValue)
        self.setValue(0, forKey: Attribute.lastPageId.rawValue) // TODO: lastIndex 수정 예정
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        self.setValue(header.updatedDate, forKey: Attribute.updatedDate.rawValue)
        print("Section: \(header.sid) save complete")
    }
}

// MARK: Generated accessors for problemCores
extension Section_Core {
    @objc(insertObject:inProblemCoresAtIndex:)
    @NSManaged public func insertIntoProblemCores(_ value: Problem_Core, at idx: Int)

    @objc(removeObjectFromProblemCoresAtIndex:)
    @NSManaged public func removeFromProblemCores(at idx: Int)

    @objc(insertProblemCores:atIndexes:)
    @NSManaged public func insertIntoProblemCores(_ values: [Problem_Core], at indexes: NSIndexSet)

    @objc(removeProblemCoresAtIndexes:)
    @NSManaged public func removeFromProblemCores(at indexes: NSIndexSet)

    @objc(replaceObjectInProblemCoresAtIndex:withObject:)
    @NSManaged public func replaceProblemCores(at idx: Int, with value: Problem_Core)

    @objc(replaceProblemCoresAtIndexes:withProblemCores:)
    @NSManaged public func replaceProblemCores(at indexes: NSIndexSet, with values: [Problem_Core])

    @objc(addProblemCoresObject:)
    @NSManaged public func addToProblemCores(_ value: Problem_Core)

    @objc(removeProblemCoresObject:)
    @NSManaged public func removeFromProblemCores(_ value: Problem_Core)

    @objc(addProblemCores:)
    @NSManaged public func addToProblemCores(_ values: NSOrderedSet)

    @objc(removeProblemCores:)
    @NSManaged public func removeFromProblemCores(_ values: NSOrderedSet)
}
