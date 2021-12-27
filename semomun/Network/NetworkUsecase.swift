//
//  NetworkUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

class NetworkUsecase {
    enum URL {
        static let base: String = "http://www.saemomoon.com:8080"
        static let workbooks: String = base + "/workbooks/"
        static let sections: String = base + "/sections/"
        static let preview: String = workbooks + "preview"
        static let images: String = base + "/images"
        static let workbookImageURL: String = images + "/workbook"
        static let bookcoverImageURL: String = images + "/bookcover"
        static let sectionImageURL: String = images + "/section"
        static let materialImage: String = images + "/material/"
        static let contentImage: String = images + "/content/"
        static let explanation: String = images + "/explanation/"
        static let checkUser: String = base + "/auth/login"
        static let categorys: String = base + "/login/info/category"
        static let majors: String = base + "/login/info/major"
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
    
    static func downloadPreviews(param: [String: String], hander: @escaping(SearchPreview) -> ()) {
        Network.get(url: URL.preview, param: param) { data in
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
    
    static func postCheckUser(userToken: String, userLoginMethod: UserLoginMethod, completion: @escaping(Bool?) -> Void) {
        let paramKey: String = userLoginMethod.getToken()
        let param = [paramKey: userToken]
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
    
    static func postUserSignup(userInfo: [String: String], completion: @escaping(Bool?) -> Void) {
        print(userInfo)
//        Network.post(url: "TODO: signUp url 필요", param: param) { data in
//            guard let data = data else {
//                print("Error: no data")
//                completion(nil)
//                return
//            }
//            // TODO: 수신 객체 필요
            completion(true)
//        }
    }
    
    static func getCheckPhone(with phone: String, completion: @escaping(Bool?) -> Void) {
//        Network.get(url: "TODO: url", param: ["phone" : phone]) { data in
//            guard let data = data else {
//                print("Error: no data")
//                completion(nil)
//                return
//            }
//            guard let validate: Validate = try? JSONDecoder().decode(Validate.self, from: data) else {
//                print("Error: Decode")
//                completion(nil)
//                return
//            }
            completion(true)
//        }
    }
    
    static func getCheckCertification(with certifi: String, completion: @escaping(Bool?) -> Void) {
//        Network.get(url: "TODO: url", param: ["certifi" : certifi]) { data in
//            guard let data = data else {
//                print("Error: no data")
//                completion(nil)
//                return
//            }
//            guard let validate: Validate = try? JSONDecoder().decode(Validate.self, from: data) else {
//                print("Error: Decode")
//                completion(nil)
//                return
//            }
            completion(true)
//        }
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
    
    static func getQeuryButtons(category: String, completion: @escaping([QueryListButton]?) -> Void) {
        var fileName: String = "수능및모의고사"
        switch category {
        case "수능 및 모의고사":
            fileName = "수능및모의고사"
            break
        default:
            return
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
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
