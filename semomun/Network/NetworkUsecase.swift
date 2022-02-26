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
                    print("\(optional: String(data: data, encoding: .utf8))")
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

extension NetworkUsecase {
    func homeResult(requestResult: RequestResult, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
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
        completion(.SUCCESS, searchPreview.workbooks.shuffled())
    }
}

extension NetworkUsecase: BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks, param: nil) { requestResult in
            self.homeResult(requestResult: requestResult, completion: completion)
        }
    }
}

extension NetworkUsecase: WorkbooksWithTagsFetchable {
    func getWorkbooks(tags: [String], completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks, param: nil) { requestResult in
            self.homeResult(requestResult: requestResult, completion: completion)
        }
    }
}

extension NetworkUsecase: WorkbooksWithRecentFetchable {
    func getWorkbooksWithRecent(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks, param: nil) { requestResult in
            self.homeResult(requestResult: requestResult, completion: completion)
        }
    }
}

extension NetworkUsecase: WorkbooksWithNewestFetchable {
    func getWorkbooksWithNewest(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void) {
        self.network.get(url: NetworkURL.workbooks, param: nil) { requestResult in
            self.homeResult(requestResult: requestResult, completion: completion)
        }
    }
}

extension NetworkUsecase: PopularTagsFetchable {
    func getPopularTags(completion: @escaping (NetworkStatus, [String]) -> Void) {
        let dummyTags = ["국가 기술 자격","수학의 정석","기업 적성검사","해커스어학연구소","취업/상식","좋은책신사고","국가직 7급 공무원","국사편찬위원회","쎈","교육청","대한상공회의소","수능","국사편찬위원회"]
        completion(.SUCCESS, dummyTags+dummyTags)
        self.getCategorys { categorys in
            guard var categorys = categorys else { return }
            categorys.append("자격증")
            completion(.SUCCESS, categorys+dummyTags+dummyTags)
        }
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
        var category: String = "수능모의고사"
        self.getCategorys { categorys in
            guard var categorys = categorys else {
                completion(.ERROR, [])
                return
            }
            categorys.append("자격증")
            if let firstTag = tags.first,
               categorys.contains(firstTag) {
                category = firstTag
            }
            
            func testSearch() {
                let param = ["c": category]
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
            
            testSearch()
        }
    }
}

//extension NetworkUsecase: BookshelfFetchable {
//    func getBooks(completion: @escaping (NetworkStatus, [TestBook]) -> Void) {
//        let book1 = TestBook("수능형 공무원 모의고사", "권규호", "권규호언어연구실")
//        let book2 = TestBook("마더텅 수능 기출 전국연합 학력평가 20분 미니 모의고사 24회 고1 영어 영역", "마더텅 편집부", "마더텅")
//        let book3 = TestBook("해커스 토익 실전 1000제 READING 1 문제집", "해커스 어학연구소", "해커스어학연구소")
//        let book4 = TestBook("2021 수능 영어 기출문제 단어∙숙어∙관용표현 완전정리", "우슬초", "이페이지")
//        let book5 = TestBook("수능영어 기출변형 모의고사 1000제 : 기출문제의 치밀한 분석과 응용", "이광희, 서성원", "한국문화사")
//        let book6 = TestBook("자이스토리 전국연합 모의고사 고1영어 [12회]", "신수진, 윤승남, 이아영 등", "수경출판사")
//        let testBooks = [book1, book2, book3, book4, book5, book6]
//        completion(.SUCCESS, testBooks+testBooks)
//    }
//}

extension NetworkUsecase: MajorFetchable {
    func getMajors(completion: @escaping([Major]?) -> Void) {
        self.network.get(url: NetworkURL.majors, param: nil) { requestResult in
            guard let data = requestResult.data else {
                completion(nil)
                return
            }
            guard let majors: MajorFetched = try? JSONDecoder().decode(MajorFetched.self, from: data) else {
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
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping(NetworkStatus) -> Void) {
        guard let nickName = userInfo.nickName else { return }
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {
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
                    print("\(optional: String(data: data, encoding: .utf8))")
                }
                completion(.ERROR)
                return
            }
            completion(.SUCCESS)
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
            let wids = searchPreview.workbooks.map(\.wid)
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
    func downloadWorkbook(wid: Int, handler: @escaping(SearchWorkbook) -> ()) {
        self.network.get(url: NetworkURL.workbookDirectory(wid), param: nil) { requestResult in
            guard let data = requestResult.data else { return }
            print(String(data: data, encoding: .utf8))
            guard let searchWorkbook: SearchWorkbook = try? JSONDecoder().decode(SearchWorkbook.self, from: data) else {
                print("Error: Decode")
                return
            }
            handler(searchWorkbook)
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
                print("server Error")
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
                print("\(optional: String(data: data, encoding: .utf8))")
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


extension NetworkUsecase: S3ImageFetchable {
    func getImageFromS3(uuid: String, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, String?) -> Void) {
        let param = ["uuid": uuid, "type": type.rawValue]
        self.network.get(url: NetworkURL.s3ImageDirectory, param: param) { requestResult in
            guard let statusCode = requestResult.statusCode else {
                print("Error: no statusCode")
                completion(.ERROR, nil)
                return
            }
            if statusCode == 504 {
                print("server Error")
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
                print("\(optional: String(data: data, encoding: .utf8))")
                completion(.ERROR, nil)
                return
            }
            guard let imageUrl: String = String(data: data, encoding: .utf8) else {
                print("Error: Decode")
                completion(.DECODEERROR, nil)
                return
            }
            completion(.SUCCESS, imageUrl)
        }
    }
}
