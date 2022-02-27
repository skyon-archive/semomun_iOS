//
//  SignUpInfo.swift
//  semomun
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

class UserInfo: Codable, CustomStringConvertible {
    var description: String {
        return "User(\(optional: self.uid), \(optional: self.name), \(optional: self.nickName), \(optional: self.phoneNumberWithCountryCode), \(optional: self.favoriteCategory), \(optional: self.major), \(optional: self.majorDetail), \(optional: self.gender), \(optional: self.birthday), \(optional: self.school), \(optional: self.graduationStatus))"
    }
    var name: String?
    var nickName: String?
    private(set) var phoneNumberWithCountryCode: String?
    var favoriteCategory: String?
    var major: String?
    var majorDetail: String?
    var gender: String?
    var birthday: String?
    var school: String?
    var graduationStatus: String?
    var uid: String?
    var profileImage: Data?
    
    var phoneNumber: String? {
        get {
            guard self.phoneNumberWithCountryCode?.isValidPhoneNumberWithCountryCode == true else { return nil }
            return self.phoneNumberWithCountryCode?.replacingOccurrences(of: "^\\+82-(\\d{1,2})-(\\d{4})-(\\d{4})$", with: "0$1$2$3", options: .regularExpression, range: nil)
        }
        set {
            guard newValue?.isValidPhoneNumber == true else { return }
            self.phoneNumber = newValue?.replacingOccurrences(of: "^0(\\d{1,2})(\\d{4})(\\d{4})$", with: "+82-$1-$2-$3", options: .regularExpression, range: nil)
        }
    }
    
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
            self.phoneNumberWithCountryCode = phone
        } else {
            self.phoneNumberWithCountryCode = String.randomPhoneNumber
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
        return [self.nickName, self.phoneNumberWithCountryCode, self.major, self.majorDetail, self.school, self.graduationStatus].allSatisfy {
            $0 != nil && $0 != ""
        }
    }
    
    func setValues(userInfo: UserCoreData) {
        self.name = userInfo.name
        self.nickName = userInfo.nickName
        self.phoneNumberWithCountryCode = userInfo.phoneNumber
        self.favoriteCategory = userInfo.favoriteCategory
        self.major = userInfo.major
        self.majorDetail = userInfo.majorDetail
        self.gender = userInfo.gender
        self.birthday = userInfo.birthday
        self.school = userInfo.schoolName
        self.graduationStatus = userInfo.graduationStatus
    }
}
