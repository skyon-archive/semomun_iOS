//
//  CertificationUseCase.swift
//  semomun
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
        let nameChecker = "^[가-힣A-Za-z]{2,10}"
        let result = resultOfPredicate(text: name, cheker: nameChecker)
        self.delegate?.nameResult(result: result == true ? .valid : .error)
    }
    
    func checkPhone(with phone: String?) {
        //11글자의 숫자
        guard let phone = phone, phone.count > 0 else {
            self.delegate?.phoneResult(result: .error)
            return
        }
        let phoneChecker = "^[0-9]{11}"
        let result = resultOfPredicate(text: phone, cheker: phoneChecker)
        self.delegate?.phoneResult(result: result == true ? .valid : .error)
    }
    
    func checkCertification(with certification: String?) {
        //6글자의 숫자
        guard let certification = certification, certification.count > 0 else {
            self.delegate?.certificationResult(result: .error)
            return
        }
        let certificationChecker = "^[0-9]{6}"
        let result = resultOfPredicate(text: certification, cheker: certificationChecker)
        self.delegate?.certificationResult(result: result == true ? .valid : .error)
    }
    
    func resultOfPredicate(text: String, cheker: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", cheker)
        let result = predicate.evaluate(with: text)
        return result
    }
    
    func isValidForSignUp(states: [Bool]) -> Bool {
        var result: Bool = true
        states.forEach { result = result && $0 }
        return result
    }
}
