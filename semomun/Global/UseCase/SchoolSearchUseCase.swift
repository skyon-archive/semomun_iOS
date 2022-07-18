//
//  SchoolSearchUseCase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/28.
//

import Foundation

struct SchoolSearchUseCase {
    let networkUseCase: NetworkUsecase?
    
    init(networkUseCase: NetworkUsecase) {
        self.networkUseCase = networkUseCase
    }
    
    enum SchoolType: String, CaseIterable {
        case elementary = "초등학교"
        case middle = "중학교"
        case high = "고등학교"
        case univ = "대학교"
        case alter = "대안"
        case special = "특수/기타"
        
        var key: String {
            switch self {
            case .elementary: return "elem_list"
            case .middle: return "midd_list"
            case .high: return "high_list"
            case .univ: return "univ_list"
            case .special: return "seet_list"
            case .alter: return "alte_list"
            }
        }
    }
    
    func request(schoolKey: String, completion: @escaping ([String]) -> Void) {
        guard let apiKey = Bundle.main.infoDictionary?["API_ACCESS_KEY1"] as? String else {
            completion([])
            return
        }
        let param = [
            "apiKey": apiKey,
            "svcType": "api",
            "svcCode": "SCHOOL",
            "contentType": "json",
            "gubun": schoolKey,
            "thisPage": "1",
            "perPage": "20000"
        ]
        self.networkUseCase?.getSchoolNames(param: param, completion: completion)
    }
}
