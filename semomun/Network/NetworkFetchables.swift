//
//  NetworkFetchables.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

typealias networkFetchables = (PagesFetchable & VersionFetchable)

// Network
protocol NetworkFetchable {
    func get(url: String, param: [String: String]?, completion: @escaping (RequestResult) -> Void)
    func post(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
    func put(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
}
// NetworkUseCase
protocol PagesFetchable {
    func getPages(sid: Int, hander: @escaping ([PageOfDB]) -> Void)
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
