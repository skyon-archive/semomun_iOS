//
//  NetworkUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

class NetworkUsecase {
    let network: NetworkFetchable
    init(network: NetworkFetchable) {
        self.network = network
    }
    
    func downloadPreviews(param: [String: String], hander: @escaping(SearchPreview) -> ()) {
        self.network.get(url: NetworkURL.workbooks, param: param) { requestResult in
            guard let data = requestResult.data else { return }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(searchPreview)
        }
    }
    
    func downloadImage(url: String, hander: @escaping(Data) -> ()) {
        self.network.get(url: url, param: nil) { requestResult in
            guard let data = requestResult.data else { return }
            hander(data)
        }
    }
    
    func downloadWorkbook(wid: Int, handler: @escaping(SearchWorkbook) -> ()) {
        self.network.get(url: NetworkURL.workbookDirectory(wid), param: nil) { requestResult in
            guard let data = requestResult.data else { return }
            guard let searchWorkbook: SearchWorkbook = try? JSONDecoder().decode(SearchWorkbook.self, from: data) else {
                print("Error: Decode")
                return
            }
            handler(searchWorkbook)
        }
    }
    
    func downloadImageData(url: String, handler: @escaping(Data?) -> Void) {
        self.network.get(url: url, param: nil) { requestResult in
            handler(requestResult.data)
        }
    }
    
    func getCategorys(completion: @escaping([String]?) -> Void) {
        self.network.get(url: NetworkURL.categorys, param: nil) { requestResult in
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
    
    func getMajors(completion: @escaping([[String: [String]]]?) -> Void) {
        self.network.get(url: NetworkURL.majors, param: nil) { requestResult in
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
    
    func getQueryButtons(category: String, completion: @escaping([QueryListButton]?) -> Void) {
        self.network.get(url: NetworkURL.queryButtons, param: ["c": category]) { requestResult in
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
    
    func getSchoolDTO(param: [String: String], completion: @escaping ([String]) -> Void) {
        self.network.get(url: NetworkURL.schoolApi, param: param) { requestResult in
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
    
    func getUserInfo(completion: @escaping(NetworkStatus, UserInfo?) -> Void) {
        let url = NetworkURL.users+"self"
        let param: [String: String] = ["token": KeychainItem.currentUserIdentifier]
        
        self.network.get(url: url, param: param) { requestResult in
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
}

// MARK: - POST
extension NetworkUsecase {
    func postCheckUser(userToken: String, completion: @escaping(NetworkStatus,Bool) -> Void) {
        let param = ["token": userToken]
        self.network.post(url: NetworkURL.checkUser, param: param) { requestResult in
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
    
    func postUserSignup(userInfo: UserInfo, completion: @escaping(NetworkStatus) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        
        self.network.post(url: NetworkURL.register, param: param) { requestResult in
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
}

// MARK: - PUT
extension NetworkUsecase {
    func putUserInfoUpdate(userInfo: UserCoreData, completion: @escaping(NetworkStatus) -> Void) {
        guard let nickName = userInfo.nickName else { return }
        let newUserInfo = UserInfo()
        newUserInfo.setValues(userInfo: userInfo)
        guard let jsonData = try? JSONEncoder().encode(newUserInfo) else {
            print("Encode Error")
            return
        }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let param: [String: String] = ["info": jsonStringData, "token": KeychainItem.currentUserIdentifier]
        
        self.network.put(url: NetworkURL.users+"\(nickName)", param: param) { requestResult in
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
    
    func putSectionResult(sid: Int, submissions: String, completion: @escaping(NetworkStatus) -> Void) {
        let param = ["submissions": submissions, "token": KeychainItem.currentUserIdentifier]
        self.network.put(url: NetworkURL.sectionsSubmit(sid), param: param) { requestResult in
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

extension NetworkUsecase: PagesFetchable {
    func getPages(sid: Int, hander: @escaping ([PageOfDB]) -> Void) {
        self.network.get(url: NetworkURL.sectionDirectory(sid), param: nil) { requestResult in
            guard let data = requestResult.data else { return }
            guard let pageOfDBs: [PageOfDB] = try? JSONDecoder().decode([PageOfDB].self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(pageOfDBs)
        }
    }
}

extension NetworkUsecase: VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, AppstoreVersion?) -> Void) {
        self.network.get(url: NetworkURL.appstoreVersion, param: nil) { requestResult in
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

extension NetworkUsecase: BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        let param = ["c": "수능모의고사"]
        self.network.get(url: NetworkURL.workbooks, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode,
                  let data = requestResult.data else {
                print("Error: no requestResult")
                completion(.ERROR, [])
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode), \(String(data: data, encoding: .utf8)!)")
                completion(.ERROR, [])
                return
            }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, searchPreview.workbooks)
        }
    }
}

extension NetworkUsecase: WorkbooksWithTagsFetchable {
    func getWorkbooks(tags: [String], completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        let param = ["c": "법학적성시험"]
        self.network.get(url: NetworkURL.workbooks, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode,
                  let data = requestResult.data else {
                print("Error: no requestResult")
                completion(.ERROR, [])
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode), \(String(data: data, encoding: .utf8)!)")
                completion(.ERROR, [])
                return
            }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, searchPreview.workbooks)
        }
    }
}

extension NetworkUsecase: WorkbooksWithRecentFetchable {
    func getWorkbooksWithRecent(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        let param = ["c": "공인회계사시험"]
        self.network.get(url: NetworkURL.workbooks, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode,
                  let data = requestResult.data else {
                print("Error: no requestResult")
                completion(.ERROR, [])
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode), \(String(data: data, encoding: .utf8)!)")
                completion(.ERROR, [])
                return
            }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, searchPreview.workbooks)
        }
    }
}

extension NetworkUsecase: WorkbooksWithNewestFetchable {
    func getWorkbooksWithNewest(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        let param = ["c": "국가직9급공무원시험"]
        self.network.get(url: NetworkURL.workbooks, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode,
                  let data = requestResult.data else {
                print("Error: no requestResult")
                completion(.ERROR, [])
                return
            }
            if statusCode != 200 {
                print("Error: \(statusCode), \(String(data: data, encoding: .utf8)!)")
                completion(.ERROR, [])
                return
            }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, searchPreview.workbooks)
        }
    }
}

extension NetworkUsecase: PopularTagsFetchable {
    func getPopularTags(completion: @escaping (NetworkStatus, [String]) -> Void) {
        let dumyTags = ["국가 기술 자격","수학의 정석","기업 적성검사","해커스어학연구소","취업/상식","좋은책신사고","국가직 7급 공무원","국사편찬위원회","쎈","교육청","대한상공회의소","수능","국사편찬위원회"]
        completion(.SUCCESS, dumyTags+dumyTags)
    }
}
