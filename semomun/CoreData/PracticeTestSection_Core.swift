//
//  PracticeTestSection_Core+CoreDataProperties.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/23.
//
//

import Foundation
import CoreData


@objc(PracticeTestSection_Core)
public class PracticeTestSection_Core: NSManagedObject {
    public override var description: String{
        return "PracticeTestSection(\(sid))\n" + (problemCores ?? []).map(\.description).joined(separator: "\n")
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PracticeTestSection_Core> {
        return NSFetchRequest<PracticeTestSection_Core>(entityName: "PracticeTestSection_Core")
    }
    
    enum Attribute: String {
        case wid
        case sid
        case title
        case detail
        case lastIndex
        case terminated
        case scoringQueue
        case uploadProblemQueue
        case uploadPageQueue
        case updatedDate
        case audio
        case audioDetail
        case problemCores
        case cutoff
        case subject
        case area
        case deviation
        case averageScore
    }
    /* section */
    @NSManaged public var wid: Int64
    @NSManaged public var sid: Int64
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var lastIndex: Int64
    @NSManaged public var terminated: Bool
    @NSManaged public var scoringQueue: [Int]?
    @NSManaged public var uploadProblemQueue: [Int]?
    @NSManaged public var uploadPageQueue: [Int]?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var audio: Data?
    @NSManaged public var audioDetail: String?
    @NSManaged public var problemCores: [Problem_Core]?
    /* practiceTest */
    @NSManaged public var cutoff: String?
    @NSManaged public var subject: String?
    @NSManaged public var area: String?
    @NSManaged public var deviation: Int64
    @NSManaged public var averageScore: Int64
    
    func setValues(section: SectionOfDB, workbook: Preview_Core) {
        /// section 정보 저장
        self.setValue(Int64(section.wid), forKey: Attribute.wid.rawValue)
        self.setValue(Int64(section.sid), forKey: Attribute.sid.rawValue)
        self.setValue(section.title, forKey: Attribute.title.rawValue)
        self.setValue(section.detail, forKey: Attribute.detail.rawValue)
        self.setValue(nil, forKey: Attribute.cutoff.rawValue)
        self.setValue(nil, forKey: Attribute.audio.rawValue)
        self.setValue(nil, forKey: Attribute.audioDetail.rawValue)
        self.setValue(section.updatedDate, forKey: Attribute.updatedDate.rawValue)
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        /// practiceTest 정보 저장
        self.setValue(workbook.cutoff, forKey: Attribute.cutoff.rawValue) //등급계산을 위한 데이터
        self.setValue(workbook.subject, forKey: Attribute.subject.rawValue) //과목 이름
        self.setValue(workbook.area, forKey: Attribute.area.rawValue) //영역 이름
        self.setValue(workbook.deviation, forKey: Attribute.deviation.rawValue) //표준 편차
        self.setValue(workbook.averageScore, forKey: Attribute.averageScore.rawValue) //평균 점수
    }
}

// MARK: Generated accessors for problemCores
extension PracticeTestSection_Core {

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
