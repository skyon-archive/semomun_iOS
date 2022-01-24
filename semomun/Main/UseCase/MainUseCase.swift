//
//  MainUseCase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

typealias MainFetchables = (PagesFetchable & VersionFetchable)

protocol MainLogic {
    func getVersion (completion: @escaping ((NetworkStatus, AppstoreVersion?) -> Void))
    func getPages(sid: Int, completion: @escaping (([PageOfDB]) -> Void))
    func updateVersion(with appstoreVersion: String) -> Bool
    func savePages(sid: Int, pages: [PageOfDB], loading: LoadingDelegate, completion: @escaping(Section_Core?) -> Void)
}

class MainUseCase: MainLogic {
    let networkUseCase: MainFetchables
    init(networkUseCase: MainFetchables) {
        self.networkUseCase = networkUseCase
    }
    
    func getVersion(completion: @escaping ((NetworkStatus, AppstoreVersion?) -> Void)) {
        self.networkUseCase.getAppstoreVersion { status, versionDTO in
            completion(status, versionDTO)
        }
    }
    
    func getPages(sid: Int, completion: @escaping (([PageOfDB]) -> Void)) {
        self.networkUseCase.getPages(sid: sid) { views in
            completion(views)
        }
    }
    
    func updateVersion(with appstoreVersion: String) -> Bool {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            print("Error: can't read version")
            return false
        }
        print(version, appstoreVersion)
        guard var transedVersion = Int(version.split(separator: ".").map { String($0) }.reduce("", +)) else { return false }
        guard var transedAppstoreVersion = Int(appstoreVersion.split(separator: ".").map { String($0) }.reduce("", +)) else { return false }
        if transedVersion < 100 { transedVersion *= 10 }
        if transedAppstoreVersion < 100 { transedAppstoreVersion *= 10 }
        
        return transedVersion < transedAppstoreVersion
    }
    
    func savePages(sid: Int, pages: [PageOfDB], loading: LoadingDelegate, completion: @escaping(Section_Core?) -> Void) {
        CoreUsecase.savePages(sid: sid, pages: pages, loading: loading) { section in
            completion(section)
        }
    }
}