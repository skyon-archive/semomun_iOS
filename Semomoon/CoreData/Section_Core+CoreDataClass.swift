//
//  Section_Core+CoreDataClass.swift
//  Semomoon
//
//  Created by Yoonho Shin on 2021/09/22.
//
//

import Foundation
import CoreData

@objc(Section_Core)
public class Section_Core: NSManagedObject {

}

public class View_core: NSObject{
    var vid: Int64
    var index_start: Int64
    var index_end: Int64
    var material: Int64
    var form: Int64
    var problems: [Problem_Real]

    override init(){
        vid = 0
        index_start = 0
        index_end = 0
        material = 0
        form = 0
        problems = []
    }
}
