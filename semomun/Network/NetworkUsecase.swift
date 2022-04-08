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
        self.network.request(url: NetworkURL.workbooks, method: .get, tokenRequired: false) { result in
            switch result.statusCode {
            case 200:
                guard let data = result.data,
                      let searchPreviews: SearchPreviews = try? JSONDecoderWithDate().decode(SearchPreviews.self, from: data) else {
                          print("Decode Error")
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
    func getNotices(completion: @escaping ((NetworkStatus, [UserNotice])) -> Void) {
        
        let sample = UserNotice(title: "[공지] 앱 업데이트 안내", date: Date(), content: """
안녕하세요. 세모문입니다.

세모페이에서 이용 가능한 결제사가 추가될 예정으로 안내드립니다.

- 추가 일시 : 2022년 2월 1일 오전 10시

- 추가 내용 : 세모페이에서 카카오뱅크, NH투자증권, SBI저축은행 등록 및 결제 가능

앞으로도 더 나은 서비스를 위해 노력하는 세모문이 되겠습니다.

감사합니다.
""")
        completion((.SUCCESS, Array(repeating: sample, count: 10)))
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
                      let searchPreviews: SearchPreviews = try? JSONDecoderWithDate().decode(SearchPreviews.self, from: data) else {
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
                  let workbookOfDB: WorkbookOfDB = try? JSONDecoderWithDate().decode(WorkbookOfDB.self, from: data) else {
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
                  let sectionOfDB = try? JSONDecoderWithDate().decode(SectionOfDB.self, from: data) else {
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
    // TODO: putUserInfoUpdagte 로 합쳐질 예정
    func postMarketingConsent(isConsent: Bool, completion: @escaping (NetworkStatus) -> Void)  {
        print("마케팅 수신 동의 \(isConsent)로 post 시도")
        completion(.SUCCESS)
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
                  let decoded = try? JSONDecoderWithDate().decode(PayHistoryGroupOfDB.self, from: data) else {
                      completion(.DECODEERROR, nil)
                      return
                  }
            let payHistory = PayHistory(networkDTO: decoded)
            
            completion(NetworkStatus(statusCode: statusCode), payHistory)
        }
    }
}
extension NetworkUsecase: UserInfoFetchable {
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
                let userInfo = try JSONDecoderWithDate().decode(UserInfo.self, from: data)
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
                      let bookshelfInfos: [BookshelfInfoOfDB] = try? JSONDecoderWithDate().decode([BookshelfInfoOfDB].self, from: data) else {
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
                      let bookshelfInfos: [BookshelfInfoOfDB] = try? JSONDecoderWithDate().decode([BookshelfInfoOfDB].self, from: data) else {
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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        self.network.request(url: NetworkURL.enterWorkbook, param: log, method: .put, encoder: encoder, tokenRequired: true) { result in
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
        let encoder = JSONEncoder()
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
        let encoder = JSONEncoder()
        self.network.request(url: NetworkURL.submissionOfPages, param: ["submissions": pages], method: .post, encoder: encoder, tokenRequired: true) { result in
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
        let userToken = try JSONDecoderWithDate().decode(NetworkTokens.self, from: data)
        try userToken.save()
    }
}
