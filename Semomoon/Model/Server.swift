//
//  DataBase.swift
//  Semomoon
//
//  Created by qwer on 2021/09/26.
//

import Foundation

class Server {
    static let baseURL: String = "https://ccee-118-36-227-50.ngrok.io"
    static let previewDirectory: String = baseURL + "/workbooks/preview/"
    static let workbookImageDirectory: String = baseURL + "/images/workbook/"
    
    enum scale: String {
        case small = "64x64/"
        case normal = "128x128/"
        case large = "256x256/"
    }
    
    static func workbookImageDirectory(scale: scale) -> String {
        return Server.workbookImageDirectory+scale.rawValue
    }
}
