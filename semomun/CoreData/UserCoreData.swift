//
//  UserCoreData.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/22.
//
//

import Foundation
import CoreData

extension UserCoreData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
        return NSFetchRequest<UserCoreData>(entityName: "UserCoreData")
    }

    @NSManaged public var name: String?
    @NSManaged public var nickName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var favoriteCategory: String?
    @NSManaged public var major: String?
    @NSManaged public var majorDetail: String?
    @NSManaged public var gender: String?
    @NSManaged public var birthday: String?
    @NSManaged public var schoolName: String?
    @NSManaged public var graduationStatus: String?
    @NSManaged public var userImage: Data?
    @NSManaged public var uid: String?
}

extension UserCoreData : Identifiable {
}


@objc(UserCoreData)
public class UserCoreData: NSManagedObject {
    public override var description: String{
        return "User(\(optional: self.uid), \(optional: self.name), \(optional: self.nickName), \(optional: self.phoneNumber), \(optional: self.favoriteCategory), \(optional: self.major), \(optional: self.majorDetail), \(optional: self.gender), \(optional: self.birthday), \(optional: self.schoolName), \(optional: self.graduationStatus))"
    }
    
    func setValues(userInfo: UserInfo) {
        print("class: \(userInfo)")
        self.setValue(userInfo.name, forKey: "name")
        self.setValue(userInfo.username, forKey: "nickName")
        self.setValue(userInfo.phoneNumber, forKey: "phoneNumber")
        self.setValue(userInfo.major, forKey: "major")
        self.setValue(userInfo.majorDetail, forKey: "majorDetail")
        self.setValue(userInfo.gender, forKey: "gender")
        self.setValue(userInfo.birth, forKey: "birthday")
        self.setValue(userInfo.school, forKey: "schoolName")
        self.setValue(userInfo.graduationStatus, forKey: "graduationStatus")
        self.setValue(String(userInfo.uid), forKey: "uid")
    }
    
    func setUserImage(imageData: Data) {
        self.setValue(imageData, forKey: "userImage")
    }
}
