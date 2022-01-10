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
        static let users: String = base + "/users/"
        
        static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
        static let customerService: String = "http://pf.kakao.com/_JAxdGb"
        static let errorReport: String = "https://forms.gle/suXByYKEied6RcSd8"
        static let appstoreVersion: String = "https://itunes.apple.com/lookup?id=1601145709"
        
        static var workbookImageDirectory: (scale) -> String = { workbookImageURL + $0.rawValue }
        static var bookcovoerImageDirectory: (scale) -> String = { bookcoverImageURL + $0.rawValue }
        static var sectionImageDirectory: (scale) -> String = { sectionImageURL + $0.rawValue }
        static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
        static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
        static var sectionsSubmit: (Int) -> String = { sections + "\($0)" + "/submission" }
    }
    enum scale: String {
        case small = "/64x64/"
        case normal = "/128x128/"
        case large = "/256x256/"
    }
    enum NetworkStatus {
        case SUCCESS //200
        case FAIL
        case ERROR
        case INSPECTION //504
        case DECODEERROR
    }
    
    static func downloadPreviews(param: [String: String], hander: @escaping(SearchPreview) -> ()) {
        Network.get(url: URL.workbooks, param: param) { requestResult in
            guard let data = requestResult.data else { return }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(searchPreview)
        }
    }
    
    static func downloadImage(url: String, hander: @escaping(Data) -> ()) {
        Network.get(url: url) { requestResult in
            guard let data = requestResult.data else { return }
            hander(data)
        }
    }
    
    static func downloadWorkbook(wid: Int, handler: @escaping(SearchWorkbook) -> ()) {
        Network.get(url: URL.workbookDirectory(wid)) { requestResult in
            guard let data = requestResult.data else { return }
            guard let searchWorkbook: SearchWorkbook = try? JSONDecoder().decode(SearchWorkbook.self, from: data) else {
                print("Error: Decode")
                return
            }
            handler(searchWorkbook)
        }
    }
    
    static func downloadPages(sid: Int, hander: @escaping([PageOfDB]) -> ()) {
        Network.get(url: URL.sectionDirectory(sid)) { requestResult in
            guard let data = requestResult.data else { return }
            guard let pageOfDBs: [PageOfDB] = try? JSONDecoder().decode([PageOfDB].self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(pageOfDBs)
        }
    }
    
    static func downloadImageData(url: String, handler: @escaping(Data?) -> Void) {
        Network.get(url: url) { requestResult in
            handler(requestResult.data)
        }
    }
    
    static func getCategorys(completion: @escaping([String]?) -> Void) {
        Network.get(url: URL.categorys) { requestResult in
            guard let data = requestResult.data else {
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
        Network.get(url: URL.majors) { requestResult in
            guard let data = requestResult.data else {
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
        Network.get(url: URL.queryButtons, param: ["c": category]) { requestResult in
            guard let data = requestResult.data else {
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
        Network.get(url: NetworkUsecase.URL.schoolApi, param: param) { requestResult in
            guard let data = requestResult.data else {
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
    
    static func getUserInfo(completion: @escaping(NetworkStatus, UserInfo?) -> Void) {
        let url = URL.users+"self"
        let param: [String: String] = ["token": KeychainItem.currentUserIdentifier]
        
        Network.get(url: url, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR, nil)
                return
            }
            if statusCode == 504 {
                completion(.INSPECTION, nil)
                return
            }
            guard let data = requestResult.data else {
                print("Error: no data")
                completion(.ERROR, nil)
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode)")
                print(String(data: data, encoding: .utf8))
                completion(.ERROR, nil)
                return
            }
            guard let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, nil)
                return
            }
            completion(.SUCCESS, userInfo)
        }
    }
    
    static func getAppstoreVersion(completion: @escaping(NetworkStatus, AppstoreVersion?) -> Void) {
        Network.get(url: URL.appstoreVersion) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR, nil)
                return
            }
            guard let data = requestResult.data else {
                print("no data")
                completion(.ERROR, nil)
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode)")
                print(String(data: data, encoding: .utf8)!)
                completion(.ERROR, nil)
                return
            }
            guard let appstoreVersion: AppstoreVersion = try? JSONDecoder().decode(AppstoreVersion.self, from: data) else {
                print("Decode Error")
                completion(.DECODEERROR, nil)
                return
            }
            completion(.SUCCESS, appstoreVersion)
        }
    }
}

// MARK: - POST
extension NetworkUsecase {
    static func postCheckUser(userToken: String, completion: @escaping(NetworkStatus,Bool) -> Void) {
        let param = ["token": userToken]
        Network.post(url: URL.checkUser, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR, false)
                return
            }
            if statusCode == 504 {
                completion(.INSPECTION, false)
                return
            } else if statusCode != 200 {
                print("Error: \(statusCode)")
                completion(.ERROR, false)
                return
            }
            guard let data = requestResult.data else {
                print("Error: no data")
                completion(.ERROR, false)
                return
            }
            guard let validate: Validate = try? JSONDecoder().decode(Validate.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, false)
                return
            }
            completion(.SUCCESS, validate.check)
        }
    }
    
    static func postUserSignup(userInfo: UserInfo, completion: @escaping(NetworkStatus) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        
        Network.post(url: URL.register, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR)
                return
            }
            if statusCode == 504 {
                print("server Error")
                completion(.INSPECTION)
                return
            }
            guard let data = requestResult.data else {
                print("Error: no data")
                completion(.ERROR)
                return
            }
            let uid = String(data: data, encoding: .utf8)!
            print(uid)
            if statusCode != 200 {
                print("Error: \(statusCode)")
                completion(.ERROR)
                return
            }
            completion(.SUCCESS)
        }
    }
    
    static func postCheckPhone(with phone: String, completion: @escaping(Bool?) -> Void) {
        completion(true)
    }
    
    static func postCheckCertification(with certifi: String, phone: String, completion: @escaping(Bool?) -> Void) {
        completion(true)
    }
}

// MARK: - PUT
extension NetworkUsecase {
    static func putUserInfoUpdate(userInfo: UserCoreData, completion: @escaping(NetworkStatus) -> Void) {
        guard let nickName = userInfo.nickName else { return }
        let newUserInfo = UserInfo()
        newUserInfo.setValues(userInfo: userInfo)
        guard let jsonData = try? JSONEncoder().encode(newUserInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        
        Network.put(url: URL.users+"\(nickName)", param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR)
                return
            }
            if statusCode == 504 {
                print("server Error")
                completion(.INSPECTION)
                return
            } else if statusCode != 200 {
                print("Error: \(statusCode)")
                if let data = requestResult.data {
                    print(String(data: data, encoding: .utf8))
                }
                completion(.ERROR)
                return
            }
            completion(.SUCCESS)
        }
    }
    
    static func putSectionResult(sid: Int, submissions: String, completion: @escaping(NetworkStatus) -> Void) {
        let param = ["submissions": submissions, "token": KeychainItem.currentUserIdentifier]
        Network.put(url: URL.sectionsSubmit(sid), param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR)
                return
            }
            if statusCode == 504 {
                print("server Error")
                completion(.INSPECTION)
                return
            } else if statusCode != 200 {
                print("Error: \(statusCode)")
                if let data = requestResult.data {
                    print(String(data: data, encoding: .utf8))
                }
                completion(.ERROR)
                return
            }
            completion(.SUCCESS)
        }
    }
}
