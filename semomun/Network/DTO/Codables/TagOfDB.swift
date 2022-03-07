//
 //  TagOfDB.swift
 //  semomun
 //
 //  Created by Kang Minsang on 2022/03/03.
 //

 import Foundation

 struct SearchTags: Decodable {
     let count: Int
     let tags: [TagOfDB]
 }

 struct TagOfDB: Codable {
     let tid: Int
     let name: String
 }
