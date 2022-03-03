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
    
    func downloadPreviews(param: [String: String], completion: @escaping (SearchPreviews) -> ()) {
        self.network.get(url: NetworkURL.workbooks, param: param) { result in
            guard let data = result.data else { return }
            guard let searchPreview: SearchPreviews = try? JSONDecoder().decode(SearchPreviews.self, from: data) else {
                print("Decode error")
                return
            }
            completion(searchPreview)
        }
    }
    
    func getSchoolDTO(param: [String: String], completion: @escaping ([String]) -> Void) {
        self.network.get(url: NetworkURL.schoolApi, param: param) { result in
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

extension NetworkUsecase {
    enum UserIDToken {
        case google(String)
        case apple(String)
        var paramValue: (type: String, token: String) {
            switch self {
            case .google(let string):
                return ("google", string)
            case .apple(let string):
                return ("apple", string)
            }
        }
    }
    func postUserLogin(userToken: UserIDToken, completion: @escaping (NetworkStatus) -> Void) {
        let paramValue = userToken.paramValue
        let param = ["token": paramValue.token, "type": paramValue.type]
        self.network.post(url: NetworkURL.login, param: param) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION)
            case 200:
                do {
                    guard let data = result.data else {
                        completion(.DECODEERROR)
                        return
                    }
                    let userToken = try JSONDecoder().decode(NetworkTokens.self, from: data)
                    try userToken.save()
                    completion(.SUCCESS)
                } catch {
                    print(error)
                    completion(.DECODEERROR)
                }
            default:
                completion(.ERROR)
            }
        }
    }
    
    func postUserSignup(userIDToken: UserIDToken, userInfo: SignUpUserInfo, completion: @escaping (NetworkStatus) -> Void) {
        let paramValue = userIDToken.paramValue
        let param = SignUpParam(info: userInfo, token: paramValue.type, type: paramValue.token)
        self.network.post(url: NetworkURL.signup, param: param) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION)
            case 200:
                guard let data = result.data,
                      let userToken = try? JSONDecoder().decode(NetworkTokens.self, from: data) else {
                          print("Error: no data")
                          completion(.DECODEERROR)
                          return
                      }
                print(userToken)
                do {
                    try userToken.save()
                } catch {
                    print(error.localizedDescription)
                }
                completion(.SUCCESS)
            default:
                completion(.ERROR)
            }
        }
    }
}

extension NetworkUsecase {
    func putSectionResult(sid: Int, submissions: String, completion: @escaping(NetworkStatus) -> Void) {
        let param = ["submissions": submissions, "token": KeychainItem.currentUserIdentifier]
        self.network.put(url: NetworkURL.sectionsSubmit(sid), param: param) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION)
            case 200:
                completion(.SUCCESS)
            default:
                completion(.ERROR)
            }
        }
    }
}

extension NetworkUsecase: SectionDownloadable {
    func getSection(sid: Int, completion: @escaping (SectionOfDB) -> Void) {
        self.network.get(url: NetworkURL.sectionDirectory(sid)) { result in
            guard let data = result.data,
                  let section: SectionOfDB = try? JSONDecoderWithDate().decode(SectionOfDB.self, from: data) else {
                      print("Decode error")
                      return
                  }
            completion(section)
        }
    }
}

extension NetworkUsecase: VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, AppstoreVersion?) -> Void) {
        self.network.get(url: NetworkURL.appstoreVersion) { result in
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
                completion(.ERROR, nil)
            }
        }
    }
}

extension NetworkUsecase: BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks) { result in
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
                completion(.ERROR, [])
            }
        }
    }
}

extension NetworkUsecase: WorkbooksWithTagsFetchable {
    func getWorkbooks(tags: [String], completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks) { result in
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
                completion(.ERROR, [])
            }
        }
    }
}

extension NetworkUsecase: WorkbooksWithRecentFetchable {
    func getWorkbooksWithRecent(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks) { result in
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
                completion(.ERROR, [])
            }
        }
    }
}

extension NetworkUsecase: WorkbooksWithNewestFetchable {
    func getWorkbooksWithNewest(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks) { result in
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
                completion(.ERROR, [])
            }
        }
    }
}

extension NetworkUsecase: PopularTagsFetchable {
    func getPopularTags(completion: @escaping (NetworkStatus, [String]) -> Void) {
        let dummyTags = ["국가 기술 자격","수학의 정석","기업 적성검사","해커스어학연구소","취업/상식","좋은책신사고","국가직 7급 공무원","국사편찬위원회","쎈","교육청","대한상공회의소","수능","국사편찬위원회"]
        completion(.SUCCESS, dummyTags+dummyTags)
    }
}

extension NetworkUsecase: SearchTagsFetchable {
    func getTagsFromSearch(text: String, complection: @escaping (NetworkStatus, [String]) -> Void) {
        let dummyTags = ["수능","수학","수학1","수학2","수리논술","수학가형","수학나형","수리"]
        complection(.SUCCESS, dummyTags)
    }
}

extension NetworkUsecase: SearchFetchable {
    func getSearchResults(tags: [String], text: String, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks) { result in
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
                completion(.ERROR, [])
            }
        }
    }
}

extension NetworkUsecase: MajorFetchable {
    func getMajors(completion: @escaping ([Major]?) -> Void) {
        self.network.get(url: NetworkURL.majors) { result in
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

extension NetworkUsecase: UserInfoSendable {
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping (NetworkStatus) -> Void) {
        self.network.put(url: NetworkURL.usersSelf, param: userInfo) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION)
            case 200:
                completion(.SUCCESS)
            default:
                completion(.ERROR)
            }
        }
    }
}

extension NetworkUsecase: NicknameCheckable {
    func checkRedundancy(ofNickname nickname: String, completion: @escaping ((NetworkStatus, Bool)) -> Void) {
        if nickname == "홍길동" {
            completion((.SUCCESS, true))
        } else {
            completion((.SUCCESS, false))
        }
    }
}

extension NetworkUsecase: PhonenumVerifiable {
    func requestVertification(of phonenum: String, completion: @escaping (NetworkStatus) -> ()) {
        completion(.SUCCESS)
    }
    
    func checkValidity(of authNum: String, completion: @escaping (Bool) -> Void) {
        completion(authNum == "1234")
    }
}

extension NetworkUsecase: SemopayHistoryFetchable {
    func getSemopayHistory(completion: @escaping ((NetworkStatus, [SemopayHistory])) -> Void) {
        let makeRandomPastDate: () -> Date = {
            let randomTimeInterval = Double.random(in: -10000000...0)
            return Date().addingTimeInterval(randomTimeInterval)
        }
        let makeRandomCost: () -> Double = {
            return Double(Int.random(in: -99...99) * 1000)
        }
        self.downloadPreviews(param: [:]) { searchPreview in
            let wids = searchPreview.previews.map(\.wid)
            let testData: [SemopayHistory] = Array(1...20).map { _ in
                let cost = makeRandomCost()
                let wid = cost > 0 ? nil : wids.randomElement()
                return SemopayHistory(wid: wid, date: makeRandomPastDate(), cost: cost)
            }.sorted(by: { $0.date > $1.date })
            // 정렬은 프론트에서? 백에서?
            completion((.SUCCESS, testData))
        }
    }
}

extension NetworkUsecase: PurchaseListFetchable {
    func getPurchaseList(from startDate: Date, to endDate: Date, completion: @escaping ((NetworkStatus, [Purchase])) -> Void) {
        guard startDate <= endDate else { return }
        let wids = Array(30...79)
        let dates = Array(1...50).map { Date(timeIntervalSinceNow: -86400 * 5 * Double($0)) }
        let purchases = Array(0..<50).map { Purchase(wid: wids[$0], date: dates[$0], cost: Double.random(in: 1...99) * 1000)}
        completion((.SUCCESS, purchases))
    }
}

extension NetworkUsecase: WorkbookFetchable {
    func downloadWorkbook(wid: Int, completion: @escaping (WorkbookOfDB) -> ()) {
        self.network.get(url: NetworkURL.workbookDirectory(wid)) { result in
            guard let data = result.data,
                  let workbookOfDB: WorkbookOfDB = try? JSONDecoderWithDate().decode(WorkbookOfDB.self, from: data) else {
                      print("Decode error")
                      return
                  }
            completion(workbookOfDB)
        }
    }
}

extension NetworkUsecase: RemainingSemopayFetchable {
    func getRemainingSemopay(completion: @escaping ((NetworkStatus, Int)) -> Void) {
        completion((.SUCCESS, 1000000))
    }
}

extension NetworkUsecase: UserNoticeFetchable {
    func getUserNotices(completion: @escaping ((NetworkStatus, [UserNotice])) -> Void) {
        
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

extension NetworkUsecase: MarketingConsentSendable {
    func postMarketingConsent(isConsent: Bool, completion: @escaping (NetworkStatus) -> Void)  {
        print("마케팅 수신 동의 \(isConsent)로 post 시도")
        completion(.SUCCESS)
    }
}

extension NetworkUsecase: ErrorReportable {
    func postProblemError(pid: Int, text: String, completion: @escaping (NetworkStatus) -> Void) {
        print(pid, text)
        completion(.SUCCESS)
    }
}

extension NetworkUsecase: UserInfoFetchable {
    func getUserInfo(completion: @escaping (NetworkStatus, UserInfo?) -> Void) {
        self.network.get(url: NetworkURL.usersSelf) { result in
            switch result.statusCode {
            case 504:
                completion(.INSPECTION, nil)
            case 200:
                do {
                    guard let data = result.data else {
                        completion(.ERROR, nil)
                        return
                    }
                    let userInfo = try JSONDecoderWithDate().decode(UserInfo.self, from: data)
                    completion(.SUCCESS, userInfo)
                } catch {
                    print(error)
                    completion(.DECODEERROR, nil)
                    return
                }
            default:
                completion(.ERROR, nil)
            }
        }
    }
}


extension NetworkUsecase: S3ImageFetchable {
    func getImageFromS3(uuid: UUID, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, Data?) -> Void) {
        let param = ["uuid": uuid.uuidString.lowercased(), "type": type.rawValue]
        self.network.get(url: NetworkURL.s3ImageDirectory, param: param) { result in
            guard let data = result.data,
                  let imageURL: String = String(data: data, encoding: .utf8) else {
                      completion(.FAIL, nil)
                      return
                  }
            
            self.network.get(url: imageURL) { result in
                let status: NetworkStatus = result.statusCode == 200 ? .SUCCESS : .FAIL
                completion(status, result.data)
            }
        }
    }
}
