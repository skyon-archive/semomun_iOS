//
//  DataBase.swift
//  Semomoon
//
//  Created by qwer on 2021/09/26.
//

import Foundation

class Network {
    static let base: String = "https://957c-118-36-227-50.ngrok.io/"
    static let workbooks: String = base + "workbooks/"
    static let sections: String = base + "sections/"
    static let preview: String = workbooks + "preview/"
    static let workbookImageURL: String = base + "images/workbook/"
    
    enum scale: String {
        case small = "64x64/"
        case normal = "128x128/"
        case large = "256x256/"
    }
    
    static func workbookImageDirectory(scale: scale) -> String {
        let url = Network.workbookImageURL+scale.rawValue
        return url
    }
    
    static func workbookDirectory(wid: Int) -> String {
        let url = Network.workbooks+"\(wid)"
        return url
    }
    
    static func sectionDirectory(sid: Int) -> String {
        let url = Network.sections+"\(sid)"
        return url
    }
    
    static func downloadPreviews(queryItems: [URLQueryItem], hander: @escaping(SearchPreview) -> ()) {
        guard var components = URLComponents(string: Network.preview) else { return }
        components.queryItems = queryItems
        guard let dbURL = components.url else { return }
        
        let request = URLRequest(url: dbURL)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            if let getJsonData: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) {
                hander(getJsonData)
            }
        }
        task.resume()
    }
    
    static func downloadSection(sid: Int, hander: @escaping([ViewOfDB]) -> ()) {
        guard let url = URL(string: Network.sectionDirectory(sid: sid)) else {
            print("URL is nil")
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            if let getJsonData: [ViewOfDB] = try? JSONDecoder().decode([ViewOfDB].self, from: data) {
                hander(getJsonData)
            }
        }
        task.resume()
    }
}
