//
//  NetworkFetchables.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation
import Alamofire

// MARK: - Network
protocol NetworkFetchable {
    func request(url: String, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void)

    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void)
    
    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, encoder: JSONEncoder, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void)
}

// MARK: - Fetchable
protocol VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, AppstoreVersion?) -> Void)
}
protocol BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol TagsFetchable {
    func getTags(order: NetworkURL.TagsOrder, completion: @escaping (NetworkStatus, [TagOfDB]) -> Void)
}
protocol MajorFetchable {
    func getMajors(completion: @escaping([Major]?) -> Void)
}
protocol SchoolNamesFetchable {
    func getSchoolNames(param: [String: String], completion: @escaping ([String]) -> Void)
}
protocol NoticeFetchable {
    func getNotices(completion: @escaping ((NetworkStatus, [UserNotice])) -> Void)
}
protocol S3ImageFetchable {
    func getImageFromS3(uuid: UUID, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, Data?) -> Void)
}
// MARK: - Searchable
protocol PreviewsSearchable {
    func getPreviews(tags: [TagOfDB], text: String, page: Int, limit: Int, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol WorkbookSearchable {
    func getWorkbook(wid: Int, completion: @escaping (WorkbookOfDB) -> ())
}
// MARK: - Downloadable
protocol SectionDownloadable {
    func downloadSection(sid: Int, completion: @escaping (SectionOfDB) -> Void)
}
// MARK: - Chackable
protocol NicknameCheckable {
    func checkRedundancy(ofNickname nickname: String, completion: @escaping (NetworkStatus, Bool) -> Void)
}
protocol PhonenumVerifiable {
    func requestVerification(of phoneNumber: String, completion: @escaping (NetworkStatus) -> ())

    func checkValidity(phoneNumber: String, code: String, completion: @escaping (NetworkStatus, Bool?) -> Void)
}
// MARK: - UserAccessable
protocol UserInfoSendable {
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping(NetworkStatus) -> Void)
    func postMarketingConsent(isConsent: Bool, completion: @escaping (NetworkStatus) -> Void)
}
protocol UserHistoryFetchable {
    func getPayHistory(onlyPurchaseHistory: Bool, page: Int, completion: @escaping (NetworkStatus, PayHistory?) -> Void)
}
protocol UserInfoFetchable {
    func getUserInfo(completion: @escaping(NetworkStatus, UserInfo?) -> Void)
    func getRemainingPay(completion: @escaping (NetworkStatus, Int?) -> Void)
}
protocol UserPurchaseable {
    func purchaseItem(productIDs: [Int], completion: @escaping (NetworkStatus, Int?) -> Void)
}
protocol UserWorkbooksFetchable {
    func getUserBookshelfInfos(completion: @escaping (NetworkStatus, [BookshelfInfoOfDB]) -> Void)
    func getUserBookshelfInfos(order: NetworkURL.PurchasesOrder, completion: @escaping (NetworkStatus, [BookshelfInfoOfDB]) -> Void)
}
protocol UserLogSendable {
    func sendWorkbookEnterLog(wid: Int, datetime: Date)
}
protocol UserSubmissionSendable {
    func postProblemSubmissions(problems: [SubmissionProblem], completion: @escaping (NetworkStatus) -> Void)
    func postPageSubmissions(pages: [SubmissionPage], completion: @escaping (NetworkStatus) -> Void)
}
// MARK: - Reportable
protocol ErrorReportable {
    func postProblemError(pid: Int, text: String, completion: @escaping (NetworkStatus) -> Void)
}
// MARK: - Login&Signup
protocol LoginSignupPostable {
    func postLogin(userToken: NetworkURL.UserIDToken, completion: @escaping ((status: NetworkStatus, userNotExist: Bool)) -> Void)
    func postSignup(userIDToken: NetworkURL.UserIDToken, userInfo: SignupUserInfo, completion: @escaping ((status: NetworkStatus, userAlreadyExist: Bool)) -> Void)
}
