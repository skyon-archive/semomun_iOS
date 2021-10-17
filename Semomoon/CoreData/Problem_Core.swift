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

    @NSManaged public var pid: Int64 //문제 고유번호
    @NSManaged public var pName: String? //하단버튼 표시내용
    @NSManaged public var contentImage: Data? //문제 이미지
    @NSManaged public var time: Int64 //누적시간
    @NSManaged public var answer: String? //정답
    @NSManaged public var solved: String? //사용자 입력답
    @NSManaged public var correct: Bool //맞았는지 여부
    @NSManaged public var explanationImage: Data? //해설 이미지
    @NSManaged public var rate: Int64 //0~100 정답률
    @NSManaged public var drawing: Data? //펜슬데이터
    @NSManaged public var type: Int64 //문제타입: 0,1,4,5
    @NSManaged public var star: Bool //별표표시여부
}

extension Problem_Core : Identifiable {

}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    func setValues(prob: ProblemOfDB){
        self.setValue(Int64(prob.pid), forKey: "pid")
        self.setValue(prob.icon_name, forKey: "pName")
        self.setValue(nil, forKey: "contentImage")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(prob.answer, forKey: "answer")
        self.setValue(nil, forKey: "solved")
        self.setValue(false , forKey: "correct")
        self.setValue(nil , forKey: "explanationImage") // temporary
        self.setValue(prob.rate, forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(prob.type, forKey: "type")
        self.setValue(false, forKey: "star")
    }
    
    func updateContentImage(data: Data?) {
        self.setValue(data, forKey: "contentImage")
    }
    
    func updateExplanationImage(data: Data?) {
        self.setValue(data, forKey: "explanationImage")
    }
}
