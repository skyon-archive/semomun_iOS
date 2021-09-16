//
//  Preview_Core+CoreDataClass.swift
//  Preview_Core
//
//  Created by qwer on 2021/09/15.
//
//

import Foundation
import CoreData

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
//    init(entity: NSEntityDescription, context: NSManagedObjectContext?, preview_real: Preview_Real){
//        super.init(entity: entity, insertInto: context)
//        self.wid = Int64(preview_real.preview.wid)
//        self.image = preview_real.imageData
//        self.title = preview_real.preview.title
//    }
    public override var description: String{
        return "preview of \(String(describing: self.title)), wid is \(self.wid)"
    }
    
    // functions to replace the custom initialization methods
    func preview2core(preview: Preview){
        self.setValue(preview.wid, forKey: "wid")
        self.setValue(preview.title, forKey: "title")
        self.setValue(preview.image, forKey: "image")
    }
    
    func preview2core(wid: Int64, title: String, image: Data?){
        self.setValue(wid, forKey: "wid")
        self.setValue(title, forKey: "title")
        self.setValue(image, forKey: "image")
    }
    
    
}
