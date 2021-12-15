//
//  CertificationUseCase.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/14.
//

import Foundation

protocol Certificateable: AnyObject {
    func nameResult(result: CertificationUseCase.Results)
    func phoneResult(result: CertificationUseCase.Results)
    func certificationResult(result: CertificationUseCase.Results)
}

class CertificationUseCase {
    weak var delegate: Certificateable?
    enum Results {
        case valid
        case error
    }
    
    init(delegate: Certificateable) {
        self.delegate = delegate
    }
    
    func checkName(with name: String?) {
        //한글, 또는 영어만의 3~10글자
        guard let name = name, name.count > 0 else {
            self.delegate?.nameResult(result: .error)
            return
        }
        let nameChecker = "^[가-힣A-Za-z]{3,10}"
        let result = resultOfPredicate(text: name, cheker: nameChecker)
        self.delegate?.nameResult(result: result == true ? .valid : .error)
    }
    
    func checkPhone(with: String?) {
        
    }
    
    func checkCertification(with: String?) {
        
    }
    
    func resultOfPredicate(text: String, cheker: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", cheker)
        let result = predicate.evaluate(with: text)
        return result
    }
}
