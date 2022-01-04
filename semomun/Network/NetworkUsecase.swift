//
//  NetworkUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

class NetworkUsecase {
    enum URL {
        static let base: String = "https://saemomoon.com"
        static let workbooks: String = base + "/workbooks/"
        static let sections: String = base + "/sections/"
        static let images: String = base + "/images"
        static let workbookImageURL: String = images + "/workbook"
        static let bookcoverImageURL: String = images + "/bookcover"
        static let sectionImageURL: String = images + "/section"
        static let materialImage: String = images + "/material/"
        static let contentImage: String = images + "/content/"
        static let explanation: String = images + "/explanation/"
        static let checkUser: String = base + "/register/check"
        static let categorys: String = base + "/info/category"
        static let queryButtons: String = base + "/info/buttons"
        static let majors: String = base + "/info/major"
        static let register: String = base + "/register"
        static let postPhone: String = register + "/auth"
        static let verifyPhone: String = register + "/verify"
        static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
        
        static var workbookImageDirectory: (scale) -> String = { workbookImageURL + $0.rawValue }
        static var bookcovoerImageDirectory: (scale) -> String = { bookcoverImageURL + $0.rawValue }
        static var sectionImageDirectory: (scale) -> String = { sectionImageURL + $0.rawValue }
        static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
        static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
    }
    enum scale: String {
        case small = "/64x64/"
        case normal = "/128x128/"
        case large = "/256x256/"
    }
    enum UserLoginMethod {
        case google, apple
        func getToken() -> String {
            switch self {
            case .apple:
                return "token_apple"
            case .google:
                return "token_google"
            }
        }
    }
    
    static func downloadPreviews(param: [String: String], hander: @escaping(SearchPreview) -> ()) {
        Network.get(url: URL.workbooks, param: param) { data in
            guard let data = data else { return }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(searchPreview)
        }
    }
    
    static func downloadImage(url: String, hander: @escaping(Data) -> ()) {
        Network.get(url: url) { data in
            guard let data = data else { return }
            hander(data)
        }
    }
    
    static func downloadWorkbook(wid: Int, handler: @escaping(SearchWorkbook) -> ()) {
        Network.get(url: URL.workbookDirectory(wid)) { data in
            guard let data = data else { return }
            guard let searchWorkbook: SearchWorkbook = try? JSONDecoder().decode(SearchWorkbook.self, from: data) else {
                print("Error: Decode")
                return
            }
            handler(searchWorkbook)
        }
    }
    
    static func downloadPages(sid: Int, hander: @escaping([PageOfDB]) -> ()) {
        Network.get(url: URL.sectionDirectory(sid)) { data in
            guard let data = data else { return }
            guard let pageOfDBs: [PageOfDB] = try? JSONDecoder().decode([PageOfDB].self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(pageOfDBs)
        }
    }
    
    static func downloadImageData(url: String, handler: @escaping(Data?) -> Void) {
        Network.get(url: url) { data in
            handler(data)
        }
    }
    
    static func getCategorys(completion: @escaping([String]?) -> Void) {
        Network.get(url: URL.categorys) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let categorysDto: Categorys = try? JSONDecoder().decode(Categorys.self, from: data) else {
                print("Error: Decode")
                completion(nil)
                return
            }
            completion(categorysDto.category)
        }
    }
    
    static func getMajors(completion: @escaping([[String: [String]]]?) -> Void) {
        Network.get(url: URL.majors) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let majors: Majors = try? JSONDecoder().decode(Majors.self, from: data) else {
                print("Error: Decode")
                completion(nil)
                return
            }
            completion(majors.major)
        }
    }
    
    static func getQueryButtons(category: String, completion: @escaping([QueryListButton]?) -> Void) {
        Network.get(url: URL.queryButtons, param: ["c": category]) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let buttonsDto: CategoryQueryButtons = try? JSONDecoder().decode(CategoryQueryButtons.self, from: data) else {
                print("Error: Decode")
                completion(nil)
                return
            }
            completion(buttonsDto.queryButtons)
        }
    }
    
    static func getSchoolDTO(param: [String: String], completion: @escaping ([String]) -> Void) {
        Network.get(url: NetworkUsecase.URL.schoolApi, param: param) { data in
            guard let data = data else {
                completion([])
                return
            }
            
            guard let json = try? JSONDecoder().decode(CareerNetJSON.self, from: data) else {
                completion([])
                return
            }
            print("학교 정보 다운로드 완료")
            let schoolNames = json.dataSearch.content.map(\.schoolName)
            completion(Array(Set(schoolNames)).sorted())
        }
    }
    
    static func getUserInfo(param: [String: String], completion: @escaping(UserInfo?) -> Void) {
        guard let url = Bundle.main.url(forResource: "dummyUserInfo", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
                  completion(nil)
                  return
              }
        guard let userInfo: UserInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
            print("Error: Decode")
            completion(nil)
            return
        }
        completion(userInfo)
    }
}

// MARK: - POST
extension NetworkUsecase {
    static func postCheckUser(userToken: String, completion: @escaping(Bool?) -> Void) {
        let param = ["token": userToken]
        Network.post(url: URL.checkUser, param: param) { data in
            guard let data = data else {
                print("Error: no data")
                completion(nil)
                return
            }
            guard let validate: Validate = try? JSONDecoder().decode(Validate.self, from: data) else {
                print("Error: Decode")
                completion(nil)
                return
            }
            completion(validate.check)
        }
    }
    
    static func postUserSignup(userInfo: UserInfo, completion: @escaping(Bool?) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        Network.post(url: URL.register, param: param) { data in
            guard let data = data else {
                print("Error: no data")
                completion(nil)
                return
            }
            print(String(data: data, encoding: .utf8))
            completion(true)
        }
    }
    
    static func postCheckPhone(with phone: String, completion: @escaping(Bool?) -> Void) {
        Network.post(url: URL.postPhone, param: ["phone" : phone]) { data in
            guard let data = data else {
                print("Error: no data")
                completion(nil)
                return
            }
            print(String(data: data, encoding: .utf8))
            completion(true)
        }
    }
    
    static func postCheckCertification(with certifi: String, phone: String, completion: @escaping(Bool?) -> Void) {
        Network.post(url: URL.verifyPhone, param: ["phone" : phone, "code": certifi]) { data in
            guard let data = data else {
                print("Error: no data")
                completion(nil)
                return
            }
            print(String(data: data, encoding: .utf8))
            completion(true)
        }
    }
    
    static func postUserInfoUpdate(userInfo: UserCoreData, completion: @escaping(Bool?) -> Void) {
        let newUserInfo = UserInfo()
        newUserInfo.setValues(userInfo: userInfo)
        guard let jsonData = try? JSONEncoder().encode(newUserInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        print(param)
        completion(true)
    }
    
    static func postSectionResult(submissions: String, completion: @escaping(Bool?) -> Void) {
        let param = ["submissions": submissions, "token": KeychainItem.currentUserIdentifier]
        print(param)
        completion(true)
    }
}
