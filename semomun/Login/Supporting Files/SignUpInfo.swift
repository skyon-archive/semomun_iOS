//
//  SignUpInfo.swift
//  Semomoon
//
//  Created by Yoonho Shin on 2021/11/21.
//

import Foundation

class SignUpInfo {
    var name: String = ""
    var phoneNumber: String = ""
    var desiredCategory: [String] = []
    var field: String = ""
    var interest: [String] = []
    
    var gender: String = ""
    
    var birthday: String = ""
    var schoolName: String = ""
    var graduationStatus: String = ""
    
    func configureFirst(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
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
