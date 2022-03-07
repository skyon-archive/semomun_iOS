//
//  NetworkFetchables.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation
import Alamofire

typealias networkFetchables = (SectionDownloadable & VersionFetchable)

// Network
protocol NetworkFetchable {
    func request(url: String, method: HTTPMethod, completion: @escaping (NetworkResult) -> Void)

    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, completion: @escaping (NetworkResult) -> Void)
}
// NetworkUseCase
protocol SectionDownloadable {
    func getSection(sid: Int, completion: @escaping (SectionOfDB) -> Void)
}
protocol VersionFetchable {
    func getAppstoreVersion(completion: @escaping (NetworkStatus, AppstoreVersion?) -> Void)
}
protocol BestSellersFetchable {
    func getBestSellers(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol WorkbooksWithRecentFetchable {
    func getWorkbooksWithRecent(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol WorkbooksWithNewestFetchable {
    func getWorkbooksWithNewest(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol TagsFetchable {
    func getTags(order: NetworkURL.TagsOrder, completion: @escaping (NetworkStatus, [TagOfDB]) -> Void)
}
protocol PreviewsFetchable {
    func getSearchPreviews(tags: [TagOfDB], text: String, page: Int, limit: Int, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
//protocol BookshelfFetchable {
//    func getBooks(completion: @escaping (NetworkStatus, [TestBook]) -> Void)
//}
protocol MajorFetchable {
    func getMajors(completion: @escaping([Major]?) -> Void)
}
protocol UserInfoSendable {
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping(NetworkStatus) -> Void)
}
protocol NicknameCheckable {
    func checkRedundancy(ofNickname nickname: String, completion: @escaping ((NetworkStatus, Bool)) -> Void)
}
protocol PhonenumVerifiable {
    func requestVertification(of phonenum: String, completion: @escaping (NetworkStatus) -> ())
    func checkValidity(phoneNumber: String, authNum: String, completion: @escaping (Bool) -> Void) 
}
protocol SemopayHistoryFetchable {
    func getSemopayHistory(completion: @escaping ((NetworkStatus, [SemopayHistory])) -> Void)
}
protocol PurchaseListFetchable {
    func getPurchaseList(from startDate: Date, to endDate: Date, completion: @escaping ((NetworkStatus, [Purchase])) -> Void)
}
protocol WorkbookFetchable {
    func downloadWorkbook(wid: Int, completion: @escaping (WorkbookOfDB) -> ())
}
protocol RemainingSemopayFetchable {
    func getRemainingSemopay(completion: @escaping ((NetworkStatus, Int)) -> Void)
}
protocol UserNoticeFetchable {
    func getUserNotices(completion: @escaping ((NetworkStatus, [UserNotice])) -> Void)
}
protocol MarketingConsentSendable {
    func postMarketingConsent(isConsent: Bool, completion: @escaping (NetworkStatus) -> Void) 
}
protocol ErrorReportable {
    func postProblemError(pid: Int, text: String, completion: @escaping (NetworkStatus) -> Void)
}
protocol UserInfoFetchable {
    func getUserInfo(completion: @escaping(NetworkStatus, UserInfo?) -> Void)
    func getUserCredit(completion: @escaping (NetworkStatus, Int?) -> Void)
}
protocol S3ImageFetchable {
    func getImageFromS3(uuid: UUID, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, Data?) -> Void)
}
protocol Purchaseable {
    func purchaseItem(productIDs: [Int], completion: @escaping (NetworkStatus, Int?) -> Void)
}
protocol LogSendable {
    func sendWorkbookEnterLog(wid: Int, datetime: Date)
}
