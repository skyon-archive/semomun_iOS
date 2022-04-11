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
}

// MARK: - Fetchable
extension NetworkUsecase: VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, AppstoreVersion?) -> Void) {
        self.network.request(url: NetworkURL.appstoreVersion, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let appstoreVersion: AppstoreVersion = try? JSONDecoder().decode(AppstoreVersion.self, from: data) else {
                          print("Decode Error")
                          completion(.DECODEERROR, nil)
                          return
                      }
                completion(.SUCCESS, appstoreVersion)
            default:
                completion(.FAIL, nil)
            }
        }
    }
}
extension NetworkUsecase: BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.request(url: NetworkURL.bestsellers, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let previews = try? JSONDecoder.dateformatted.decode([PreviewOfDB].self, from: data) else {
                          print("Decode Error")
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
                      let searchTags: SearchTags = try? JSONDecoder().decode(SearchTags.self, from: data) else {
                          print("Decode Error")
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
                  let majors: MajorFetched = try? JSONDecoder().decode(MajorFetched.self, from: data) else {
                      print("Error: Decode")
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
                  let json = try? JSONDecoder().decode(CareerNetJSON.self, from: data) else {
                      print("Decode error")
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
            guard let notices = try? JSONDecoder.dateformatted.decode([UserNotice].self, from: data) else {
                completion(.DECODEERROR, [])
                return
            }
            completion(.SUCCESS, notices)
        }
    }
}
extension NetworkUsecase: S3ImageFetchable {
    func getImageFromS3(uuid: UUID, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, Data?) -> Void) {
        let param = ["uuid": uuid.uuidString.lowercased(), "type": type.rawValue]
        self.network.request(url: NetworkURL.s3ImageDirectory, param: param, method: .get, tokenRequired: false) { result in
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
    func getPreviews(tags: [TagOfDB], text: String, page: Int, limit: Int, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        let tids: String = tags.map { "\($0.tid)" }.joined(separator: ",")
        let param = ["tags": tids, "text": text, "page": "\(page)", "limit": "\(limit)"]
        self.network.request(url: NetworkURL.workbooks, param: param, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let searchPreviews: SearchPreviews = try? JSONDecoder.dateformatted.decode(SearchPreviews.self, from: data) else {
                          print("Decode error")
                          completion(.DECODEERROR, [])
                          return
                      }
                completion(.SUCCESS, searchPreviews.previews)
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
                  let workbookOfDB: WorkbookOfDB = try? JSONDecoder.dateformatted.decode(WorkbookOfDB.self, from: data) else {
                      print("Decode error")
                      return
                  }
            completion(workbookOfDB)
        }
    }
}


// MARK: - Downloadable
extension NetworkUsecase: SectionDownloadable {
    func downloadSection(sid: Int, completion: @escaping (SectionOfDB) -> Void) {
        self.network.request(url: NetworkURL.sectionDirectory(sid), method: .get, tokenRequired: true) { result in
            guard let data = result.data,
                  let sectionOfDB = try? JSONDecoder.dateformatted.decode(SectionOfDB.self, from: data) else {
                      print("Decode Error")
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
                      let isValid = try? JSONDecoder().decode(BooleanResult.self, from: data).result else {
                          print("Error: Decode")
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
                  let isValid = try? JSONDecoder().decode(BooleanResult.self, from: data).result else {
                      print("Error: Decode")
                      completion(.DECODEERROR, nil)
                      return
                  }
            
            completion(networkStatus, isValid)
        }
    }
}


// MARK: - UserAccessable
extension NetworkUsecase: UserInfoSendable {
    func putUserSelectedTags(tids: [Int], completion: @escaping (NetworkStatus) -> Void) {
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
                  let decoded = try? JSONDecoder.dateformatted.decode(PayHistoryGroupOfDB.self, from: data) else {
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
            
            guard let tags = try? JSONDecoder.dateformatted.decode([TagOfDB].self, from: data) else {
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
            
            do {
                let userInfo = try JSONDecoder.dateformatted.decode(UserInfo.self, from: data)
                completion(.SUCCESS, userInfo)
            } catch {
                print("getUserInfo Error: \(error)")
                completion(.DECODEERROR, nil)
                return
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
extension NetworkUsecase: UserWorkbooksFetchable {
    func getUserBookshelfInfos(completion: @escaping (NetworkStatus, [BookshelfInfoOfDB]) -> Void) {
        self.network.request(url: NetworkURL.purchasedWorkbooks, method: .get, tokenRequired: true) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let bookshelfInfos: [BookshelfInfoOfDB] = try? JSONDecoder.dateformatted.decode([BookshelfInfoOfDB].self, from: data) else {
                          print("Decode Error")
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
                      let bookshelfInfos: [BookshelfInfoOfDB] = try? JSONDecoder.dateformatted.decode([BookshelfInfoOfDB].self, from: data) else {
                          print("Decode Error")
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
            completion(.SUCCESS)
        }
    }
}


// MARK: - Reportable
extension NetworkUsecase: ErrorReportable {
    // TODO: 새로운 API 필요한 상태
    func postProblemError(pid: Int, text: String, completion: @escaping (NetworkStatus) -> Void) {
        print(pid, text)
        completion(.SUCCESS)
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
            
            guard let banners = try? JSONDecoder.dateformatted.decode([Banner].self, from: data) else {
                completion(.DECODEERROR, [])
                return
            }
            
            completion(NetworkStatus(statusCode: statusCode), banners)
        }
    }
}

extension NetworkUsecase: PopupFetchable {
    func getPopup(completion: @escaping (NetworkStatus, URL?) -> Void) {
        self.network.request(url: NetworkURL.popup, method: .get, tokenRequired: false) { result in
            guard let statusCode = result.statusCode,
                  let data = result.data else {
                completion(.FAIL, nil)
                return
            }
            
            do {
                let popupURL = try JSONDecoder.dateformatted.decode(Optional<URL>.self, from: data)
                completion(NetworkStatus(statusCode: statusCode), popupURL)
            } catch {
                completion(.DECODEERROR, nil)
            }
        }
    }
}
