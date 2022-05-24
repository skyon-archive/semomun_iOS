//
//  Problem_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData
import Alamofire

struct ProblemUUID {
    let content: UUID
    let explanation: UUID?
    var imageCount: Int {
        return explanation == nil ? 1 : 2
    }
    
    init(content: UUID, explanation: UUID?) {
        self.content = content
        self.explanation = explanation
    }
}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    public override var description: String{
        return "Problem(\(pid)) {btNum: \(pName ?? "-"), answer: \(answer ?? "none")}"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Problem_Core> {
        return NSFetchRequest<Problem_Core>(entityName: "Problem_Core")
    }
    
    enum Attribute: String {
        case pid
        case orderIndex
        case btType
        case pName
        case type
        case answer
        case contentImage
        case explanationImage
        case point
        case sectionCore
        case pageCore
        case time
        case solved
        case correct
        case drawing
        case star
        case terminated
        case subProblemsCount
    }

    @NSManaged public var pid: Int64 //문제 고유번호
    @NSManaged public var orderIndex: Int64 //NEW: section 내 정렬을 위한 고유순서값
    @NSManaged public var btType: String? //NEW: 문제 유형 (개념, 문제)
    @NSManaged public var pName: String? //하단 버튼 표시내용
    @NSManaged public var type: Int64 //선지 유형
    @NSManaged public var answer: String? //문제 정답
    @NSManaged public var contentImage: Data? //문제 이미지
    @NSManaged public var explanationImage: Data? //해설 이미지
    
    @NSManaged public var point: Double //문제 배점
    @NSManaged public var sectionCore: Section_Core? //relation으로 인해 생긴 SectionCore
    @NSManaged public var pageCore: Page_Core? //relation으로 인해 생긴 PageCore
    
    @NSManaged public var time: Int64 //누적시간
    @NSManaged public var solved: String? //사용자 입력답
    @NSManaged public var correct: Bool //맞았는지 여부
    @NSManaged public var drawing: Data? //펜슬데이터
    @NSManaged public var star: Bool //별표표시여부
    @NSManaged public var terminated: Bool //채점여부
    @NSManaged public var subProblemsCount: Int64 //단답형 문제수
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var rate: Int64 //Deprecated(1.1.3)
    
    func setValues(prob: ProblemOfDB, index: Int) -> ProblemUUID {
        self.setValue(Int(prob.pid), forKey: Attribute.pid.rawValue)
        self.setValue(Int(index), forKey: Attribute.orderIndex.rawValue)
        self.setValue(prob.btType, forKey: Attribute.btType.rawValue)
        self.setValue(prob.btName, forKey: Attribute.pName.rawValue)
        self.setValue(prob.type, forKey: Attribute.type.rawValue)
        self.setValue(prob.answer, forKey: Attribute.answer.rawValue)
        // MARK: prob.point 계산 로직 수정 필요
        self.setValue(prob.point ?? 0, forKey: Attribute.point.rawValue)
        self.setValue(0, forKey: Attribute.time.rawValue)
        self.setValue(nil, forKey: Attribute.solved.rawValue)
        self.setValue(false, forKey: Attribute.correct.rawValue)
        self.setValue(nil, forKey: Attribute.drawing.rawValue)
        self.setValue(false, forKey: Attribute.star.rawValue)
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        self.setValue(prob.subProblemsCount, forKey: Attribute.subProblemsCount.rawValue)
        print("Problem: \(prob.pid) save complete")
        
        return ProblemUUID(content: prob.content, explanation: prob.explanation)
    }
    
    func fetchImages(uuids: ProblemUUID, networkUsecase: S3ImageFetchable, completion: @escaping(() -> Void)) {
        // MARK: - contentImage
        networkUsecase.getImageFromS3(uuid: uuids.content, type: .content) { [weak self] status, data in
            print(data ?? "Error: \(self?.pid ?? 0) - can't get content Image")
            if data != nil {
                self?.setValue(data, forKey: Attribute.contentImage.rawValue)
                print("Problem: \(self?.pid ?? 0) save contentImage")
                completion()
            } else {
                self?.setValue(nil, forKey: Attribute.contentImage.rawValue)
                print("Problem: \(self?.pid ?? 0) save contentImage fail")
                completion()
            }
        }
        // MARK: - explanationImage
        guard let explanation = uuids.explanation else { return }
        networkUsecase.getImageFromS3(uuid: explanation, type: .explanation) { [weak self] status, data in
            print(data ?? "Error: \(self?.pid ?? 0) - can't get explanation Image")
            if data != nil {
                self?.setValue(data, forKey: Attribute.explanationImage.rawValue)
                print("Problem: \(self?.pid ?? 0) save explanationImage")
                completion()
            } else {
                print("hi")
                self?.setValue(nil, forKey: Attribute.explanationImage.rawValue)
                print("Problem: \(self?.pid ?? 0) save explanationImage fail")
                completion()
            }
        }
    } 
    
    func setMocks(pid: Int, type: Int, btName: String, imgName: String, expName: String? = nil, answer: String? = nil) {
        self.setValue(Int64(pid), forKey: "pid")
        self.setValue(btName, forKey: "pName")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(answer, forKey: "answer")
        self.setValue(false, forKey: "correct")
        self.setValue(Int64(0), forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(type), forKey: "type")
        self.setValue(false, forKey: "star")
        self.setValue(Double(5), forKey: "point")
//        let imgData = UIImage(named: imgName)!.pngData()
//        self.setValue(imgData, forKey: "contentImage")
        if let _ = expName {
//            let expData = UIImage(named: expName)!.pngData()
//            self.setValue(expData, forKey: "explanationImage")
        } else {
            self.setValue(nil, forKey: "explanationImage")
        }
        print("MOCK Problem: \(pid) save complete")
    }
}
