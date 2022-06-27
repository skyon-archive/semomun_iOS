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
    
    private func decodeRequested<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            let decoded = try JSONDecoder.dateformatted.decode(type, from: data)
            return decoded
        } catch {
            print("NetworkUsecase: \(T.self) decode failed. \(error)")
            return nil
        }
    }
}

// MARK: - Fetchable
extension NetworkUsecase: VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, String?) -> Void) {
        self.network.request(url: NetworkURL.tempBase, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let appstoreVersion = self.decodeRequested(AppstoreVersion.self, from: data) else {
                    completion(.DECODEERROR, nil)
                    return
                }
                completion(.SUCCESS, appstoreVersion.latestVersion)
            default:
                completion(.FAIL, nil)
            }
        }
    }
}
extension NetworkUsecase: BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [WorkbookPreviewOfDB]) -> Void) {
        self.network.request(url: NetworkURL.bestsellers, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let previews = self.decodeRequested([WorkbookPreviewOfDB].self, from: data) else {
                    completion(.DECODEERROR, [])
                    return
                }
                completion(.SUCCESS, previews)
            default:
                completion(.FAIL, [])
            }
        }
    }
}
extension NetworkUsecase: TagsFetchable {
    func getTags(order: NetworkURL.TagsOrder, completion: @escaping (NetworkStatus, [TagOfDB]) -> Void) {
        let param = ["order": order.rawValue]
        self.network.request(url: NetworkURL.tags, param: param, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let searchTags: SearchTags = self.decodeRequested(SearchTags.self, from: data) else {
                    completion(.DECODEERROR, [])
                    return
                }
                completion(.SUCCESS, searchTags.tags)
            default:
                completion(.FAIL, [])
            }
        }
    }
}
extension NetworkUsecase: MajorFetchable {
    func getMajors(completion: @escaping ([Major]?) -> Void) {
        self.network.request(url: NetworkURL.majors, method: .get, tokenRequired: false) { result in
            guard let data = result.data,
                  let majors: MajorFetched = self.decodeRequested(MajorFetched.self, from: data) else {
                completion(nil)
                return
            }
            let wrapped = majors.major
            let unwrapped: [Major] = wrapped.compactMap { majorFetched in
                guard let majorName = majorFetched.keys.first, let majorDetails = majorFetched[majorName] else { return nil }
                let major = Major(name: majorName, details: majorDetails)
                return major
            }
            completion(unwrapped)
        }
    }
}
extension NetworkUsecase: SchoolNamesFetchable {
    func getSchoolNames(param: [String: String], completion: @escaping ([String]) -> Void) {
        self.network.request(url: NetworkURL.schoolApi, param: param, method: .get, tokenRequired: false) { result in
            guard let data = result.data,
                  let json = self.decodeRequested(CareerNetJSON.self, from: data) else {
                completion([])
                return
            }
            print("학교 정보 다운로드 완료")
            let schoolNames = json.dataSearch.content.map(\.schoolName)
            completion(Array(Set(schoolNames)).sorted())
        }
    }
}
extension NetworkUsecase: NoticeFetchable {
    func getNotices(completion: @escaping (NetworkStatus, [UserNotice]) -> Void) {
        self.network.request(url: NetworkURL.notices, method: .get, tokenRequired: false) { result in
            guard let data = result.data else {
                completion(.FAIL, [])
                return
            }
            guard let notices = self.decodeRequested([UserNotice].self, from: data) else {
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, notices)
        }
    }
}
extension NetworkUsecase: S3ImageFetchable {
    func getImageFromS3(uuid: UUID, type: NetworkURL.ImageType, completion: @escaping (NetworkStatus, Data?) -> Void) {
        let param = ["uuid": uuid.uuidString.lowercased(), "type": type.rawValue]
        let tokenRequired = ["content", "passage", "explanation"].contains(type.rawValue)
        self.network.request(url: NetworkURL.s3ImageDirectory, param: param, method: .get, tokenRequired: tokenRequired) { result in
            guard let data = result.data,
                  let imageURL: String = String(data: data, encoding: .utf8) else {
                completion(.FAIL, nil)
                return
            }
            
            self.network.request(url: imageURL, method: .get, tokenRequired: false) { result in
                let status: NetworkStatus = result.statusCode == 200 ? .SUCCESS : .FAIL
                completion(status, result.data)
            }
        }
    }
}


// MARK: - Searchable
extension NetworkUsecase: PreviewsSearchable {
    func getPreviews(tags: [TagOfDB], text: String, page: Int, limit: Int, completion: @escaping (NetworkStatus, [WorkbookPreviewOfDB]) -> Void) {
        let tids = tags.isEmpty ? nil : tags.map(\.tid) // tags가 빈배열일때 문제인가 싶어 nil로 시도
        let param = WorkbookSearchParam(page: page, limit: limit, tids: tids, keyword: text)
        
        self.network.request(url: NetworkURL.workbooks, param: param, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let searchPreviews: SearchWorkbookPreviews = self.decodeRequested(SearchWorkbookPreviews.self, from: data) else {
                    completion(.DECODEERROR, [])
                    return
                }
                completion(.SUCCESS, searchPreviews.workbooks)
            default:
                completion(.FAIL, [])
            }
        }
    }
}
extension NetworkUsecase: WorkbookSearchable {
    func getWorkbook(wid: Int, completion: @escaping (WorkbookOfDB) -> ()) {
        self.network.request(url: NetworkURL.workbookDirectory(wid), method: .get, tokenRequired: false) { result in
            guard let data = result.data,
                  let workbookOfDB: WorkbookOfDB = self.decodeRequested(WorkbookOfDB.self, from: data) else {
                return
            }
            completion(workbookOfDB)
        }
    }
}
extension NetworkUsecase: WorkbookGroupSearchable {
    func searchWorkbookGroup(tags: [TagOfDB]?, keyword: String?, page: Int?, limit: Int?, completion: @escaping (NetworkStatus, SearchWorkbookGroups?) -> Void) {
        // MARK: network 로직 구현 필요
        let dummySearchResult = SearchWorkbookGroups(count: 1, workbookGroups: [
            WorkbookGroupPreviewOfDB(wgid: 0, itemID: 0, type: "", title: "모의고사 1회차", detail: "", groupCover: UUID(), isGroupOnlyPurchasable: false, createdDate: Date(), updatedDate: Date())
        ])
        completion(.SUCCESS, dummySearchResult)
    }
    
    func searchWorkbookGroup(wgid: Int, completion: @escaping (NetworkStatus, WorkbookGroupOfDB?) -> Void) {
        // MARK: network 로직 구현 필요
        let testFile = "TestWorkbookGroupOfDBJSON"
        if let path = Bundle.main.path(forResource: testFile, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                guard let workbookGroupOfDB: WorkbookGroupOfDB = self.decodeRequested(WorkbookGroupOfDB.self, from: data) else {
                    completion(.FAIL, nil)
                    return
                }
                completion(.SUCCESS, workbookGroupOfDB)
            } catch {
                completion(.FAIL, nil)
            }
        }
    }
}


// MARK: - Downloadable
extension NetworkUsecase: SectionDownloadable {
    func downloadSection(sid: Int, completion: @escaping (SectionOfDB?) -> Void) {
        print("////token: \(String(describing: NetworkTokens()?.accessToken))")
        print("////URL: \(NetworkURL.sectionDirectory(sid))")
        self.network.request(url: NetworkURL.sectionDirectory(sid), method: .get, tokenRequired: true) { result in
            guard let data = result.data,
                  let sectionOfDB = self.decodeRequested(SectionOfDB.self, from: data) else {
                completion(nil)
                return
            }
            completion(sectionOfDB)
        }
    }
}


// MARK: - Chackable
extension NetworkUsecase: UsernameCheckable {
    func usernameAvailable(_ nickname: String, completion: @escaping (NetworkStatus, Bool) -> Void) {
        self.network.request(url: NetworkURL.username, param: ["username": nickname], method: .get, tokenRequired: false) { result in
            if let statusCode = result.statusCode {
                guard let data = result.data,
                      let isValid = self.decodeRequested(BooleanResult.self, from: data)?.result else {
                    completion(.DECODEERROR, false)
                    return
                }
                let networkStatus = NetworkStatus(statusCode: statusCode)
                completion(networkStatus, isValid)
            } else {
                completion(.FAIL, false)
            }
        }
    }
}
extension NetworkUsecase: PhonenumVerifiable {
    func requestVerification(of phoneNumber: String, completion: @escaping (NetworkStatus) -> ()) {
        self.network.request(url: NetworkURL.requestSMS, param: ["phone": phoneNumber], method: .post, tokenRequired: false) { result in
            if let statusCode = result.statusCode {
                let networkStatus = NetworkStatus(statusCode: statusCode)
                completion(networkStatus)
            } else {
                completion(.FAIL)
            }
        }
    }
    
    func checkValidity(phoneNumber: String, code: String, completion: @escaping (NetworkStatus, Bool?) -> Void) {
        let param = ["phone": phoneNumber, "code": code]
        
        self.network.request(url: NetworkURL.verifySMS, param: param, method: .post, tokenRequired: false) { result in
            guard let statusCode = result.statusCode else {
                completion(.FAIL, nil)
                return
            }
            
            let networkStatus = NetworkStatus(statusCode: statusCode)
            
            guard let data = result.data,
                  let isValid = self.decodeRequested(BooleanResult.self, from: data)?.result else {
                completion(.DECODEERROR, nil)
                return
            }
            
            completion(networkStatus, isValid)
        }
    }
}


// MARK: - UserAccessable
extension NetworkUsecase: UserInfoSendable {
    func putUserSelectedTags(tags: [TagOfDB], completion: @escaping (NetworkStatus) -> Void) {
        let tids = tags.map(\.tid)
        self.network.request(url: NetworkURL.tagsSelf, param: tids, method: .put, tokenRequired: true) { result in
            guard let statusCode = result.statusCode else {
                completion(.FAIL)
                return
            }
            completion(NetworkStatus(statusCode: statusCode))
        }
    }
    
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping (NetworkStatus) -> Void) {
        self.network.request(url: NetworkURL.usersSelf, param: userInfo, method: .put, tokenRequired: true) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION)
            case 200:
                completion(.SUCCESS)
            default:
                completion(.FAIL)
            }
        }
    }
}
extension NetworkUsecase: UserHistoryFetchable {
    typealias PayHistoryConforming = PayHistory
    
    func getPayHistory(onlyPurchaseHistory: Bool, page: Int, completion: @escaping (NetworkStatus, PayHistoryConforming?) -> Void) {
        let type = onlyPurchaseHistory ? "order" : ""
        let param = ["type": type, "page": String(page)]
        
        self.network.request(url: NetworkURL.payHistory, param: param, method: .get, tokenRequired: true) { result in
            guard let statusCode = result.statusCode else {
                completion(.FAIL, nil)
                return
            }
            
            guard let data = result.data,
                  let decoded = self.decodeRequested(PayHistoryGroupOfDB.self, from: data) else {
                completion(.DECODEERROR, nil)
                return
            }
            let payHistory = PayHistory(networkDTO: decoded)
            
            completion(NetworkStatus(statusCode: statusCode), payHistory)
        }
    }
}
extension NetworkUsecase: UserInfoFetchable {
    func getUserSelectedTags(completion: @escaping (NetworkStatus, [TagOfDB]) -> Void) {
        self.network.request(url: NetworkURL.tagsSelf, method: .get, tokenRequired: true) { result in
            guard let data = result.data,
                  let statusCode = result.statusCode else {
                completion(.FAIL, [])
                return
            }
            
            guard let tags = self.decodeRequested([TagOfDB].self, from: data) else {
                completion(.DECODEERROR, [])
                return
            }
            
            completion(NetworkStatus(statusCode: statusCode), tags)
        }
    }
    
    func getUserInfo(completion: @escaping (NetworkStatus, UserInfo?) -> Void) {
        self.network.request(url: NetworkURL.usersSelf, method: .get, tokenRequired: true) { result in
            if let error = result.error, self.checkTokenExpire(error: error) {
                completion(.TOKENEXPIRED, nil)
                return
            }
            
            guard let statusCode = result.statusCode,
                  let data = result.data,
                  NetworkStatus(statusCode: statusCode) == .SUCCESS else {
                completion(.FAIL, nil)
                return
            }
            
            if let userInfo = self.decodeRequested(UserInfo.self, from: data) {
                completion(.SUCCESS, userInfo)
            } else {
                completion(.DECODEERROR, nil)
            }
        }
    }
    func getRemainingPay(completion: @escaping (NetworkStatus, Int?) -> Void) {
        self.network.request(url: NetworkURL.usersSelf, method: .get, tokenRequired: true) { result in
            switch result.statusCode {
            case 200:
                if let data = result.data,
                   let dto = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let credit = dto["credit"] as? Int {
                    completion(.SUCCESS, credit)
                } else {
                    completion(.FAIL, nil)
                }
            default:
                completion(.FAIL, nil)
            }
        }
    }
    private func checkTokenExpire(error: Error) -> Bool {
        if let tokenControllerError = error as? OAuthError,
           tokenControllerError == .refreshTokenExpired {
            return true
        } else {
            return false
        }
    }
}
extension NetworkUsecase: UserPurchaseable {
    func purchaseItem(productIDs: [Int], completion: @escaping (NetworkStatus, Int?) -> Void) {
        self.network.request(url: NetworkURL.purchaseItem, param: ["ids": productIDs], method: .post, tokenRequired: true) { result in
            switch result.statusCode {
            case 200:
                if let data = result.data,
                   let dto = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                    completion(.SUCCESS, dto["balance"])
                } else {
                    completion(.DECODEERROR, nil)
                }
            default:
                completion(.FAIL, nil)
            }
        }
    }
}
extension NetworkUsecase: UserWorkbookGroupsFetchable {
    func getUserWorkbookGroupInfos(wgid: Int, completion: @escaping (NetworkStatus, [Int]) -> Void) {
        // MARK: network 로직 구현 필요
        completion(.SUCCESS, [35])
    }
}
extension NetworkUsecase: UserWorkbooksFetchable {
    func getUserBookshelfInfos(completion: @escaping (NetworkStatus, [BookshelfInfoOfDB]) -> Void) {
        self.network.request(url: NetworkURL.purchasedWorkbooks, method: .get, tokenRequired: true) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let bookshelfInfos = self.decodeRequested([BookshelfInfoOfDB].self, from: data) else {
                    completion(.DECODEERROR, [])
                    return
                }
                completion(.SUCCESS, bookshelfInfos)
            default:
                completion(.FAIL, [])
            }
        }
    }
    
    func getUserBookshelfInfos(order: NetworkURL.PurchasesOrder, completion: @escaping (NetworkStatus, [BookshelfInfoOfDB]) -> Void) {
        let param = ["order": order.rawValue]
        self.network.request(url: NetworkURL.purchasedWorkbooks, param: param, method: .get, tokenRequired: true) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let bookshelfInfos = self.decodeRequested([BookshelfInfoOfDB].self, from: data) else {
                    completion(.DECODEERROR, [])
                    return
                }
                completion(.SUCCESS, bookshelfInfos)
            default:
                completion(.FAIL, [])
            }
        }
    }
}
extension NetworkUsecase: UserLogSendable {
    func sendWorkbookEnterLog(wid: Int, datetime: Date) {
        let log = WorkbookLog(wid: wid, datetime: datetime)
        
        self.network.request(url: NetworkURL.enterWorkbook, param: log, method: .put, tokenRequired: true) { result in
            if result.statusCode == 200 {
                print("send workbook log success")
            } else {
                print("Error: send workbook log")
            }
        }
    }
}

extension NetworkUsecase: UserSubmissionSendable {
    func postProblemSubmissions(problems: [SubmissionProblem], completion: @escaping (NetworkStatus) -> Void) {
        self.network.request(url: NetworkURL.submissionOfProblems, param: ["submissions": problems], method: .post, tokenRequired: true) { result in
            guard let statusCode = result.statusCode,
                  statusCode == 200 else {
                print("submission of problems ERROR")
                completion(.FAIL)
                return
            }
            print("submission of problems complete")
            completion(.SUCCESS)
        }
    }
    func postPageSubmissions(pages: [SubmissionPage], completion: @escaping (NetworkStatus) -> Void) {
        self.network.request(url: NetworkURL.submissionOfPages, param: ["submissions": pages], method: .post, tokenRequired: true) { result in
            guard let statusCode = result.statusCode,
                  statusCode == 200 else {
                print("submission of pages ERROR")
                completion(.FAIL)
                return
            }
            print("submission of pages complete")
            completion(.SUCCESS)
        }
    }
}

extension NetworkUsecase: UserTestResultFetchable {
    func getPublicTestResult(wid: Int, completion: @escaping (NetworkStatus, PublicTestResultOfDB?) -> Void) {
        // 임시 코드
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            print("getPublicTestResult: wid \(wid)")
            let result = PublicTestResultOfDB(id: 0, wid: 0, wgid: 0, sid: 0, rank: 1, rawScore: 72, deviation: 128, percentile: 96, createdDate: Date().addingTimeInterval(-1000), updatedDate: Date())
            completion(.SUCCESS, result)
        }
    }
    
    func getPrivateTestResults(wgid: Int, completion: @escaping (NetworkStatus, [PrivateTestResultOfDB]?) -> Void) {
        // 임시 코드
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if let url = Bundle.main.url(forResource: "TestPrivateTestResultOfDBJSON", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([PrivateTestResultOfDB].self, from: data)
                    completion(.SUCCESS, decoded)
                } catch {
                    completion(.FAIL, nil)
                }
            } else {
                completion(.FAIL, nil)
            }
        }
    }
}


// MARK: - Reportable
extension NetworkUsecase: ErrorReportable {
    func postProblemError(error: ErrorReport, completion: @escaping (NetworkStatus) -> Void) {
        self.network.request(url: NetworkURL.errorReportOfProblem, param: error, method: .post, tokenRequired: true) { result in
            guard let statusCode = result.statusCode else {
                completion(.FAIL)
                return
            }
            completion(NetworkStatus(statusCode: statusCode))
        }
    }
}


// MARK: - Login&Signup
extension NetworkUsecase: LoginSignupPostable {
    func postLogin(userToken: NetworkURL.UserIDToken, completion: @escaping ((status: NetworkStatus, userNotExist: Bool)) -> Void) {
        let tokenParam = userToken.param
        let param = ["token": tokenParam.token, "type": tokenParam.type]
        
        self.network.request(url: NetworkURL.login, param: param, method: .post, tokenRequired: false) { result in
            guard let statusCode = result.statusCode,
                  let data = result.data else {
                completion((.FAIL, false))
                return
            }
            
            let networkStatus = NetworkStatus(statusCode: statusCode)
            guard networkStatus == .SUCCESS else {
                let errorMessage = String(data: data, encoding: .utf8)
                completion((networkStatus, errorMessage == "USER_NOT_EXIST"))
                return
            }
            
            do {
                try self.saveToken(in: data)
                completion((.SUCCESS, false))
            } catch {
                print("회원가입 시 얻은 토큰값 저장 실패: \(error)")
                completion((.DECODEERROR, false))
            }
        }
    }
    func postSignup(userIDToken: NetworkURL.UserIDToken, userInfo: SignupUserInfo, completion: @escaping ((status: NetworkStatus, userAlreadyExist: Bool)) -> Void) {
        let tokenParam = userIDToken.param
        let param = SignUpParam(info: userInfo, token: tokenParam.token, type: tokenParam.type)
        self.network.request(url: NetworkURL.signup, param: param, method: .post, tokenRequired: false) { result in
            guard let statusCode = result.statusCode,
                  let data = result.data else {
                completion((.FAIL, false))
                return
            }
            
            let networkStatus = NetworkStatus(statusCode: statusCode)
            guard networkStatus == .SUCCESS else {
                let errorMessage = String(data: data, encoding: .utf8)
                completion((networkStatus, errorMessage == "USER_ALREADY_EXISTS"))
                return
            }
            
            do {
                try self.saveToken(in: data)
                completion((.SUCCESS, false))
            } catch {
                print("회원가입 시 얻은 토큰값 저장 실패: \(error)")
                completion((.DECODEERROR, false))
            }
        }
    }
    func resign(completion: @escaping (NetworkStatus) -> Void) {
        self.network.request(url: NetworkURL.usersSelf, method: .delete, tokenRequired: true) { result in
            guard let statusCode = result.statusCode else {
                completion(.FAIL)
                return
            }
            completion(NetworkStatus(statusCode: statusCode))
        }
    }
    
    private func saveToken(in data: Data) throws {
        let userToken = try JSONDecoder.dateformatted.decode(NetworkTokens.self, from: data)
        try userToken.save()
    }
}

extension NetworkUsecase: BannerFetchable {
    func getBanners(completion: @escaping (NetworkStatus, [Banner]) -> Void) {
        self.network.request(url: NetworkURL.banners, method: .get, tokenRequired: false) { result in
            guard let statusCode = result.statusCode,
                  let data = result.data else {
                completion(.FAIL, [])
                return
            }
            
            guard let banners = self.decodeRequested([Banner].self, from: data) else {
                completion(.DECODEERROR, [])
                return
            }
            
            completion(NetworkStatus(statusCode: statusCode), banners)
        }
    }
}

extension NetworkUsecase: PopupFetchable {
    func getNoticePopup(completion: @escaping (NetworkStatus, URL?) -> Void) {
        self.network.request(url: NetworkURL.popup, method: .get, tokenRequired: false) { result in
            guard let statusCode = result.statusCode,
                  let data = result.data else {
                completion(.FAIL, nil)
                return
            }
            if let popupURL = self.decodeRequested(Optional<URL>.self, from: data) {
                completion(NetworkStatus(statusCode: statusCode), popupURL)
            } else {
                completion(.DECODEERROR, nil)
            }
        }
    }
}
