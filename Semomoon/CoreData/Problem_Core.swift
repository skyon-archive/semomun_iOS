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
import UIKit

struct ProblemResult {
    let pid: Int
    let contentUrl: URL?
    let explanationUrl: URL?
    
    init(pid: Int, contentUrl: URL?, explanationUrl: URL?) {
        self.pid = pid
        self.contentUrl = contentUrl
        self.explanationUrl = explanationUrl
    }
}

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
    @NSManaged public var terminated: Bool //채점여부
    @NSManaged public var point: Int64 //문제 배점
}

extension Problem_Core : Identifiable {
}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    public override var description: String{
        return "Problem(\(self.pid), \(self.pName), \(self.contentImage), \(self.explanationImage), \(self.star)\n"
    }
    
    func setValues(prob: ProblemOfDB) -> ProblemResult {
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
        self.setValue(false, forKey: "terminated")
        if let point = prob.score {
            self.setValue(Int64(point), forKey: "point")
        } else {
            self.setValue(Int64(0), forKey: "point")
        }
        print("Problem: \(prob.pid) save complete")
        
        var contentUrl: URL? = nil
        if let url = URL(string: NetworkUsecase.URL.contentImage + prob.content) {
            contentUrl = url
        }
        guard let explanation = prob.explanation,
              let url = URL(string: NetworkUsecase.URL.explanation + explanation) else {
                  return ProblemResult(pid: prob.pid, contentUrl: contentUrl, explanationUrl: nil)
              }
        return ProblemResult(pid: prob.pid, contentUrl: contentUrl, explanationUrl: url)
    }
    
    func fetchImages(problemResult: ProblemResult) {
        // MARK: - contentImage
        if let contentURL = problemResult.contentUrl {
            let contentData = try? Data(contentsOf: contentURL)
            if contentData != nil {
                self.setValue(contentData, forKey: "contentImage")
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "contentImage")
            }
        } else {
            guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
            self.setValue(warningImage.pngData(), forKey: "contentImage")
        }
        
        // MARK: - explanationImage
        if let explanationURL = problemResult.explanationUrl {
            let contentData = try? Data(contentsOf: explanationURL)
            if contentData != nil {
                self.setValue(contentData, forKey: "explanationImage")
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "explanationImage")
            }
        } else {
            self.setValue(nil, forKey: "explanationImage")
        }
        print("Problem: \(problemResult.pid) save Images")
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
        self.setValue(Int64(5), forKey: "point")
        let imgData = UIImage(named: imgName)!.pngData()
        self.setValue(imgData, forKey: "contentImage")
        if let expName = expName {
            let expData = UIImage(named: expName)!.pngData()
            self.setValue(expData, forKey: "explanationImage")
        } else {
            self.setValue(nil, forKey: "explanationImage")
        }
        print("MOCK Problem: \(pid) save complete")
    }
}
