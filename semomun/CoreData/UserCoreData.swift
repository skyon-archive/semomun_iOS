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
    @NSManaged public var uid: Int64
}

extension UserCoreData : Identifiable {
}


@objc(UserCoreData)
public class UserCoreData: NSManagedObject {
    public override var description: String{
        return "User(\(self.name!), \(self.nickName!), \(self.phoneNumber!), \(self.favoriteCategory!), \(self.major!), \(self.majorDetail!), \(self.gender!), \(self.birthday!), \(self.schoolName!), \(self.graduationStatus!)\n"
    }
    
    func setValues(userInfo: UserInfo) {
        self.setValue(userInfo.name, forKey: "name")
        self.setValue(userInfo.nickName, forKey: "nickName")
        self.setValue(userInfo.phone, forKey: "phoneNumber")
        self.setValue(userInfo.favoriteCategory, forKey: "favoriteCategory")
        self.setValue(userInfo.major, forKey: "major")
        self.setValue(userInfo.majorDetail, forKey: "majorDetail")
        self.setValue(userInfo.gender, forKey: "gender")
        self.setValue(userInfo.birthday, forKey: "birthday")
        self.setValue(userInfo.school, forKey: "schoolName")
        self.setValue(userInfo.graduationStatus, forKey: "graduationStatus")
        self.setValue(userInfo.uid!, forKey: "uid")
    }
    
    func setUserImage(imageData: Data) {
        self.setValue(imageData, forKey: "userImage")
    }
}
