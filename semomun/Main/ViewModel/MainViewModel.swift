//
//  MainViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation
import Combine

class MainViewModel {
    @Published private(set) var updateToVersion: String?
    @Published private(set) var networkWarning: String?
    @Published private(set) var createLoading: Bool = false
    @Published private(set) var downloadedSection: Bool = false
    private let useCase: MainLogic
    private var downloadedPages: [PageOfDB] = []
    private(set) var selectedSid: Int?
    
    init(useCase: MainLogic) {
        self.useCase = useCase
    }
    
    func getVersion() {
        self.useCase.getVersion { status, versionDTO in
            switch status {
            case .SUCCESS:
                print("get version success")
                guard let versionDTO = versionDTO else { return }
                if !versionDTO.results.isEmpty, let version = versionDTO.results.first?.version {
                    if self.useCase.updateVersion(with: version) {
                        self.updateToVersion = version
                    }
                }
                print("version is empty list")
            case .ERROR:
                self.networkWarning = "네트워크 비정상"
            default:
                return
            }
        }
    }
    
    func getPages(sid: Int) {
        self.useCase.getPages(sid: sid) { views in
            print("NETWORK RESULT")
            print(views)
            self.downloadedPages = views
            self.createLoading = true
        }
    }
    
    func selectSection(to sid: Int) {
        self.selectedSid = sid
    }
    
    func savePages(loading: loadingDelegate) {
        guard let sid = self.selectedSid else { return }
        self.useCase.savePages(sid: sid, pages: self.downloadedPages, loading: loading) { section in
            loading.terminate()
            self.downloadedSection = true
        }
    }
}
