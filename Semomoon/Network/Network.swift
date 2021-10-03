//
//  DataBase.swift
//  Semomoon
//
//  Created by qwer on 2021/09/26.
//

import Foundation

class Network {
    static let base: String = "https://87b5-118-36-227-50.ngrok.io/"
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
        print(url)
        return url
    }
    
    static func workbookDirectory(wid: Int) -> String {
        let url = Network.workbooks+"\(wid)"
        print(url)
        return url
    }
    
    static func sectionDirectory(sid: Int) -> String {
        let url = Network.sections+"\(sid)"
        print(url)
        return url
    }
    
    static func downloadPreviews(queryItems: [URLQueryItem], hander: @escaping(SearchPreview) -> ()) {
        guard var components = URLComponents(string: Network.preview) else { return }
        components.queryItems = queryItems
        guard let dbURL = components.url else { return }
        print(dbURL)
        
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
    
    static func downloadImage(url: String, hander: @escaping(Data) -> ()) {
        guard let url = URL(string: url) else {
            print("URL is nil")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            hander(data)
        }
        task.resume()
    }
    
    static func downloadPages(sid: Int, hander: @escaping([PageOfDB]) -> ()) {
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
            
            if let getJsonData: [PageOfDB] = try? JSONDecoder().decode([PageOfDB].self, from: data) {
                hander(getJsonData)
            }
        }
        task.resume()
    }
}
