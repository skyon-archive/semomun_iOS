//
//  NetworkStatus.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/13.
//

import Foundation

enum NetworkStatus {
    case SUCCESS //200
    case BADREQUEST // 400
    case TOOMANYREQUESTS // 429
    case INSPECTION //504
    case OTHERS(statusCode: Int)
    
    case FAIL
    case ERROR
    case DECODEERROR
    case TOKENEXPIRED
}

extension NetworkStatus {
    init(statusCode: Int) {
        switch statusCode {
        case 200:
            self = .SUCCESS
        case 400:
            self = .BADREQUEST
        case 429:
            self = .TOOMANYREQUESTS
        case 504:
            self = .INSPECTION
        default:
            self = .OTHERS(statusCode: statusCode)
        }
    }
}

extension NetworkStatus: Equatable { }
