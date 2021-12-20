//
//  SignUpInfo.swift
//  semomun
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

class SignUpInfo {
    var name: String = ""
    var nickName: String = "User0000"
    var phoneNumber: String = ""
    var desiredCategory: [String] = []
    var field: String = ""
    var interest: [String] = []
    var gender: String = ""
    var birthday: String = ""
    var schoolName: String = ""
    var graduationStatus: String = ""
    var token: String = ""
    
    func configureName(to name: String) {
        self.name = name
    }
    
    func configurePhoneNumber(to phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    func configureToken(to token: String) {
        self.token = token
    }
    
    func configureGraduation(to status: String) {
        print("update status")
        self.graduationStatus = status
    }
    
    func configureSecond(desiredCategory: [String], field: String, interest: [String]) {
        self.desiredCategory = desiredCategory
        self.field = field
        self.interest = interest
    }
    
    func configureThird(birthdayYear: String, birthdayMonth: String, birthdayDay: String, schoolName: String, graduationStatus: String) {
        self.birthday = "\(birthdayYear)-\(birthdayMonth)-\(birthdayDay)"
        self.schoolName = schoolName
        self.graduationStatus = graduationStatus
    }
}

struct SignUpInfo_DB: Codable {
    var name: String
    var phoneNumber: String
    var desiredCategory: [String]
    var field: String
    var interest: [String]
    
    var gender: String
    var birthday: String
    
    var schoolName: String
    var graduationStatus: String
    
//    var token: String
}
