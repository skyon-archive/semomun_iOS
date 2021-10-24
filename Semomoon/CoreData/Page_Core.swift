//
//  Page_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData


extension Page_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page_Core> {
        return NSFetchRequest<Page_Core>(entityName: "Page_Core")
    }

    @NSManaged public var vid: Int64 //뷰어의 고유 번호
    @NSManaged public var materialImage: Data? //좌측 이미지
    @NSManaged public var layoutType: String //뷰컨트롤러 타입
    @NSManaged public var problems: [Int] //Problem: pid 값들
}

extension Page_Core : Identifiable {

}

@objc(Page_Core)
public class Page_Core: NSManagedObject {
    public override var description: String{
        return "Page(\(self.vid), \(self.problems), \(self.materialImage))\n"
    }
    
    func setValues(page: PageOfDB, pids: [Int], type: Int) {
        self.setValue(Int64(page.vid), forKey: "vid")
        self.setValue(getLayout(form: page.form, type: type), forKey: "layoutType")
        self.setValue(pids, forKey: "problems")
        guard let materialPath = page.material,
              let url = URL(string: NetworkUsecase.URL.materialImage + materialPath) else { return }
        let imageData = try? Data(contentsOf: url)
        self.setValue(imageData, forKey: "materialImage")
        print("Page: \(page.vid) save complete")
    }
    
    func updateMaterialImage(data: Data?) {
        self.setValue(data, forKey: "materialImage")
    }
    
    func getLayout(form: Int, type: Int) -> String {
        if form == 2 {
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
}
