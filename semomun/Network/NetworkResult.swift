//
//  NetworkResult.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/03.
//

import Foundation

struct NetworkResult {
    let status: NetworkStatus
    let data: Data?
    let statusCode: Int
}
