//
//  SignUpInfo.swift
//  semomun
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

struct UserInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case uid, name, username, email, gender, birth, major, majorDetail, school, graduationStatus, credit
        case phoneNumberWithCountryCode = "phone"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
    
    var uid: Int
    var name: String?
    var username: String?
    var email: String?
    var gender: String?
    var birth: String?
    var major: String?
    var majorDetail: String?
    var school: String?
    var graduationStatus: String?
    private(set) var credit: Int?
    var createdDate: Date?
    var updatedDate: Date?
    
    private(set) var phoneNumberWithCountryCode: String?
    
    var phoneNumber: String? {
        get {
            guard self.phoneNumberWithCountryCode?.isValidPhoneNumberWithCountryCode == true else { return nil }
            return self.phoneNumberWithCountryCode?.replacingOccurrences(of: "^\\+82-(\\d{1,2})-(\\d{4})-(\\d{4})$", with: "0$1$2$3", options: .regularExpression, range: nil)
        }
        set {
            self.phoneNumberWithCountryCode = newValue?.phoneNumberWithCountryCode
        }
    }
    
    var isValidSurvay: Bool {
        return [self.username, self.phoneNumberWithCountryCode, self.major, self.majorDetail, self.school, self.graduationStatus].allSatisfy {
            $0 != nil && $0 != ""
        }
    }
    
    mutating func setValues(userInfo: UserCoreData) {
        self.name = userInfo.name
        self.username = userInfo.nickName
        self.phoneNumber = userInfo.phoneNumber
        self.major = userInfo.major
        self.majorDetail = userInfo.majorDetail
        self.gender = userInfo.gender
        self.birth = userInfo.birthday
        self.school = userInfo.schoolName
        self.graduationStatus = userInfo.graduationStatus
    }
}
