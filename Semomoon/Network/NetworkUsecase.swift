//
//  DataBase.swift
//  Semomoon
//
//  Created by qwer on 2021/09/26.
//

import Foundation

class NetworkUsecase {
    enum URL {
        static let base: String = "https://87b5-118-36-227-50.ngrok.io/"
        static let workbooks: String = base + "workbooks/"
        static let sections: String = base + "sections/"
        static let preview: String = workbooks + "preview/"
        static let workbookImageURL: String = base + "images/workbook/"
        
        static var workbookImageDirectory: (scale) -> String = { workbookImageURL + $0.rawValue }
        static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
        static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
    }
    enum scale: String {
        case small = "64x64/"
        case normal = "128x128/"
        case large = "256x256/"
    }
    
    static func downloadPreviews(param: [String: String], hander: @escaping(SearchPreview) -> ()) {
        Network.post(url: URL.preview, param: param) { data in
            guard let data = data else { return }
            guard let searchPreview: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(searchPreview)
        }
    }
    
    static func downloadImage(url: String, hander: @escaping(Data) -> ()) {
        Network.get(url: url) { data in
            guard let data = data else { return }
            hander(data)
        }
    }
    
    static func downloadWorkbook(wid: Int, handler: @escaping(SearchWorkbook) -> ()) {
        Network.get(url: URL.workbookDirectory(wid)) { data in
            guard let data = data else { return }
            guard let searchWorkbook: SearchWorkbook = try? JSONDecoder().decode(SearchWorkbook.self, from: data) else {
                print("Error: Decode")
                return
            }
            handler(searchWorkbook)
        }
    }
    
    static func downloadPages(sid: Int, hander: @escaping([PageOfDB]) -> ()) {
        Network.get(url: URL.sectionDirectory(sid)) { data in
            guard let data = data else { return }
            guard let pageOfDBs: [PageOfDB] = try? JSONDecoder().decode([PageOfDB].self, from: data) else {
                print("Error: Decode")
                return
            }
            hander(pageOfDBs)
        }
    }
}
