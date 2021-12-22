//
//  SignUpInfo.swift
//  semomun
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

class UserInfo: Codable, CustomStringConvertible {
    var description: String {
        return "User(\(self.name!), \(self.nickName!), \(self.phoneNumber!), \(self.favoriteCategory!), \(self.major!), \(self.majorDetail!), \(self.gender!), \(self.birthday!), \(self.schoolName!), \(self.graduationStatus!)\n"
    }
    var name: String?
    var nickName: String?
    var phoneNumber: String?
    var favoriteCategory: String?
    var major: String?
    var majorDetail: String?
    var gender: String?
    var birthday: String?
    var schoolName: String?
    var graduationStatus: String?
    
    func configureName(to name: String) {
        self.name = name
    }
    
    func configureNickname() {
        self.nickName = "User" + String.randomUserNumber
    }
    
    func configurePhoneNumber(to phoneNumber: String) {
        self.phoneNumber = phoneNumber
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
        self.schoolName = school
    }
    
    func configureGraduation(to status: String) {
        self.graduationStatus = status
    }
    
    var isValidSurvay: Bool {
        return self.gender != nil && self.major != nil && self.majorDetail != nil
    }
}
