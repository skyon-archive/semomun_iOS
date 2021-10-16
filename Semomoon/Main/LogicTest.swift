//
//  LogicTest.swift
//  Semomoon
//
//  Created by qwer on 2021/10/16.
//

import UIKit
import CoreData

extension MainViewController{
    func problemToCore(prob: ProblemOfDB) -> Problem_Core {
        let returnData = Problem_Core(context: CoreDataManager.shared.context);
        
        returnData.setValue(prob.pid , forKey: "pid");
        returnData.setValue(Data() , forKey: "contentImage");
        returnData.setValue(0 , forKey: "time");
        returnData.setValue(prob.answer , forKey: "answer");
        returnData.setValue(nil , forKey: "solved");
        returnData.setValue(false , forKey: "correct");
        returnData.setValue(prob.explanation , forKey: "explanationImage"); // temporary
        returnData.setValue(prob.rate, forKey: "rate");
        returnData.setValue(nil, forKey: "drawing");
        returnData.setValue(prob.type, forKey: "type");
        returnData.setValue(false, forKey: "star");
        
        setImageforProblemCore(prob: returnData, img_string: prob.content)
        
        return returnData;
    }
    
    func sectionToCore(section: SectionOfDB) -> Section_Core {
        let returnData = Section_Core(context: CoreDataManager.shared.context);
        
        returnData.setValue(section.sid , forKey: "sid");
        returnData.setValue(section.title , forKey: "title");
        returnData.setValue(nil , forKey: "buttons"); // temporary
        returnData.setValue(nil , forKey: "dictionaryOfProblem"); // temporary
        returnData.setValue(nil , forKey: "stars");
        
        return returnData;
    }
    
    func pageToCore(page: PageOfDB) -> Page_Core {
        let returnData = Page_Core(context: CoreDataManager.shared.context);
        
        returnData.setValue(page.vid , forKey: "vid");
        returnData.setValue(Data() , forKey: "materialImage");
        returnData.setValue(page.form , forKey: "layoutType");
        returnData.setValue(problemDBtoPid(problems: page.problems) , forKey: "problems");
        setImageforPageCore(page: returnData, img_string: page.material)
        return returnData;
    }
    
    func problemDBtoPid(problems: [ProblemOfDB]) -> [Int64]{
        var returnData: [Int64] = [];
        problems.forEach{
            returnData.append(Int64($0.pid));
        }
        return returnData;
    }
    
    func setImageforPageCore(page: Page_Core, img_string: String?) {
        guard let imgString = img_string else { return }
        let url: String = NetworkUsecase.URL.base + imgString; // temporary
        NetworkUsecase.downloadImage(url: url) { data in
            page.updateImage(data: data)
        }
    }
    
    func setImageforProblemCore(prob: Problem_Core, img_string: String?) {
        guard let imgString = img_string else { return }
        let url: String = NetworkUsecase.URL.base + imgString; // temporary
        NetworkUsecase.downloadImage(url: url) { data in
            prob.updateImage(data: data)
        }
    }
}
