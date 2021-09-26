//
//  DataBase.swift
//  Semomoon
//
//  Created by qwer on 2021/09/26.
//

import Foundation

class Server {
    static let baseURL: String = "https://ccee-118-36-227-50.ngrok.io/"
    static let workbooksURL: String = baseURL + "workbooks/"
    static let previewURL: String = workbooksURL + "preview/"
    static let workbookImageURL: String = baseURL + "images/workbook/"
    
    
    enum scale: String {
        case small = "64x64/"
        case normal = "128x128/"
        case large = "256x256/"
    }
    
    static func workbookImageDirectory(scale: scale) -> String {
        let url = Server.workbookImageURL+scale.rawValue
        print(url)
        return url
    }
    
    static func workbookDirectory(wid: Int) -> String {
        let url = Server.workbooksURL+"\(wid)"
        print(url)
        return url
    }
}
