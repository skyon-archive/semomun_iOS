//
//  Page_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData
import UIKit

struct PageResult {
    let vid: Int
    let url: URL?
    let isImage: Bool
    
    init(vid: Int, url: URL?, isImage: Bool) {
        self.vid = vid
        self.url = url
        self.isImage = isImage
    }
}

extension Page_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page_Core> {
        return NSFetchRequest<Page_Core>(entityName: "Page_Core")
    }

    @NSManaged public var vid: Int64 //뷰어의 고유 번호
    @NSManaged public var materialImage: Data? //좌측 이미지
    @NSManaged public var layoutType: String //뷰컨트롤러 타입
    @NSManaged public var problems: [Int] //Problem: pid 값들
    @NSManaged public var drawing: Data? //Pencil 데이터
    @NSManaged public var time: Int64 // 좌우형 시간계산을 위한 화면단위 누적 시간
}

extension Page_Core : Identifiable {

}

@objc(Page_Core)
public class Page_Core: NSManagedObject {
    public override var description: String{
        return "Page(\(self.vid), \(self.problems), \(self.materialImage))\n"
    }
    
    func setValues(page: PageOfDB, pids: [Int], type: Int) -> PageResult {
        self.setValue(Int64(page.vid), forKey: "vid")
        self.setValue(getLayout(form: page.form, type: type), forKey: "layoutType")
        self.setValue(pids, forKey: "problems")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(0), forKey: "time")
        print("Page: \(page.vid) save complete")
        
        guard let materialPath = page.material else {
            return PageResult(vid: page.vid, url: nil, isImage: false)
        }
        guard let url = URL(string: NetworkUsecase.URL.materialImage + materialPath) else {
            return PageResult(vid: page.vid, url: nil, isImage: true)
        }
        return PageResult(vid: page.vid, url: url, isImage: true)
    }
    
    func setMaterial(pageResult: PageResult) {
        if !pageResult.isImage {
            self.setValue(nil, forKey: "materialImage")
            return
        }
        
        if let url = pageResult.url {
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                self.setValue(imageData, forKey: "materialImage")
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "materialImage")
            }
        } else {
            guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
            self.setValue(warningImage.pngData(), forKey: "materialImage")
        }
        print("Page: \(pageResult.vid) save Material")
    }
    
    func getLayout(form: Int, type: Int) -> String {
        if form == 0 {
            switch type {
            case 1: return SingleWithTextAnswer.identifier
            case 4: return SingleWith4Answer.identifier
            case 5: return SingleWith5Answer.identifier
            default: return SingleWith5Answer.identifier
            }
        }
        else if form == 1 {
            switch type {
            case 0: return MultipleWithNoAnswer.identifier
            case 5: return MultipleWith5Answer.identifier
            default: return MultipleWith5Answer.identifier
            }
        }
        return SingleWith5Answer.identifier
    }
    
    func setMocks(vid: Int, form: Int, type: Int, pids: [Int], mateImgName: String?) {
        self.setValue(Int64(vid), forKey: "vid")
        self.setValue(getLayout(form: form, type: type), forKey: "layoutType")
        self.setValue(pids, forKey: "problems")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(0), forKey: "time")
        if let mateImgName = mateImgName {
            let imgData = UIImage(named: mateImgName)!.pngData()
            self.setValue(imgData, forKey: "materialImage")
        } else {
            self.setValue(nil, forKey: "materialImage")
        }
        print("MOCK Page: \(vid) save complete")
    }
}
