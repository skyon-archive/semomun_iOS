//
//  Problem_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData
import Alamofire

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
    public override var description: String{
        return "Problem(\(self.pid), \(self.pName), \(self.contentImage), \(self.explanationImage), \(self.star)\n"
    }
    
    func setValues(prob: ProblemOfDB) {
        self.setValue(Int64(prob.pid), forKey: "pid")
        self.setValue(prob.icon_name, forKey: "pName")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(prob.answer, forKey: "answer")
        self.setValue(nil, forKey: "solved")
        self.setValue(false , forKey: "correct")
        self.setValue(prob.rate, forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(prob.type, forKey: "type")
        self.setValue(false, forKey: "star")
        print("//////////url : \(NetworkUsecase.URL.contentImage + prob.content)")
//        guard let contentURL = URL(string: NetworkUsecase.URL.contentImage + prob.content),
//              let explanation = prob.explanation,
//              let explanationURL = URL(string: NetworkUsecase.URL.explanation + explanation) else { return }
        guard let contentURL = URL(string: NetworkUsecase.URL.contentImage + prob.content) else { return }
        print("Problem Image : \(contentURL)")
        let contentData = try? Data(contentsOf: contentURL)
//        let explanationData = try? Data(contentsOf: explanationURL)
        self.setValue(contentData, forKey: "contentImage")
//        self.setValue(explanationData, forKey: "explanationImage")
        print("Problem: \(prob.pid) save complete")
    }
}
