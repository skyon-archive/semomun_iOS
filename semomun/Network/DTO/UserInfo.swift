//
//  SignUpInfo.swift
//  semomun
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

class UserInfo: Codable, CustomStringConvertible {
    var description: String {
        return "User(\(self.name!), \(self.nickName!), \(self.phone!), \(self.favoriteCategory!), \(self.major!), \(self.majorDetail!), \(self.gender!), \(self.birthday!), \(self.school!), \(self.graduationStatus!)\n"
    }
    var name: String?
    var nickName: String?
    var phone: String?
    var favoriteCategory: String?
    var major: String?
    var majorDetail: String?
    var gender: String?
    var birthday: String?
    var school: String?
    var graduationStatus: String?
    var uid: String?
    var profileImage: Data?
    
    func configureName(to name: String?) {
        if let name = name {
            self.name = name
        } else {
            self.name = self.nickName
        }
    }
    
    func configureNickname(to nickName: String?) {
        if let nickName = nickName {
            self.nickName = nickName
        } else {
            self.nickName = "User" + String.randomUserNumber
        }
    }
    
    func configurePhone(to phone: String?) {
        if let phone = phone {
            self.phone = phone
        } else {
            self.phone = String.randomPhoneNumber
        }
    }
    
    func configureGender(to gender: String) {
        self.gender = gender
    }
    
    func configureCategory(to category: String) {
        self.favoriteCategory = category
    }
    
    func configureMajor(to major: String) {
        self.major = major
    }
    
    func configureMajorDetail(to majorDetail: String?) {
        self.majorDetail = majorDetail
    }
    
    func configureBirthday(to birthday: String) {
        self.birthday = birthday
    }
    
    func configureSchool(to school: String) {
        self.school = school
    }
    
    func configureGraduation(to status: String) {
        self.graduationStatus = status
    }
    
    func configureUid(to uid: String) {
        self.uid = uid
    }
    
    var isValidSurvay: Bool {
        return self.gender != nil && self.major != nil && self.majorDetail != nil
    }
    
    func setValues(userInfo: UserCoreData) {
        self.name = userInfo.name
        self.nickName = userInfo.nickName
        self.phone = userInfo.phoneNumber
        self.favoriteCategory = userInfo.favoriteCategory
        self.major = userInfo.major
        self.majorDetail = userInfo.majorDetail
        self.gender = userInfo.gender
        self.birthday = userInfo.birthday
        self.school = userInfo.schoolName
        self.graduationStatus = userInfo.graduationStatus
    }
}
