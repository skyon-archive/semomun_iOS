//
//  NetworkFetchables.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

typealias networkFetchables = (SectionDownloadable & VersionFetchable)

// Network
protocol NetworkFetchable {
    func get(url: String, param: [String: String]?, completion: @escaping (RequestResult) -> Void)
    func post(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
    func put(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
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
protocol WorkbooksWithTagsFetchable {
    func getWorkbooks(tags: [String], completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol WorkbooksWithRecentFetchable {
    func getWorkbooksWithRecent(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol WorkbooksWithNewestFetchable {
    func getWorkbooksWithNewest(completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
}
protocol PopularTagsFetchable {
    func getPopularTags(completion: @escaping (NetworkStatus, [String]) -> Void)
}
protocol SearchTagsFetchable {
    func getTagsFromSearch(text: String, complection: @escaping (NetworkStatus, [String]) -> Void)
}
protocol SearchFetchable {
    func getSearchResults(tags: [String], text: String, completion: @escaping (NetworkStatus, [PreviewOfDB]) -> Void)
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
    func checkValidity(of authNum: String, completion: @escaping (Bool) -> Void)
}
protocol SemopayHistoryFetchable {
    func getSemopayHistory(completion: @escaping ((NetworkStatus, [SemopayHistory])) -> Void)
}
protocol PurchaseListFetchable {
    func getPurchaseList(from startDate: Date, to endDate: Date, completion: @escaping ((NetworkStatus, [Purchase])) -> Void)
}
protocol WorkbookFetchable {
    func downloadWorkbook(wid: Int, handler: @escaping(WorkbookOfDB) -> ()) 
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
}

protocol S3ImageFetchable {
    func getImageFromS3(uuid: String, type: NetworkURL.imageType, completion: @escaping (NetworkStatus, Data?) -> Void)
}
protocol FilterStatus {
    func getStatusAndData(requestResult: RequestResult) -> (status: NetworkStatus, data: Data?)
}
