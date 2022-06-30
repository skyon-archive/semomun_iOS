//
//  WorkbookGroupResultButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import UIKit

final class WorkbookGroupResultButton: UIButton {
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
    }
    
    func configureDisabledUI() {
        self.borderColor = UIColor(.semoLightGray)
        self.setTitleColor(UIColor(.semoLightGray), for: .normal)
    }
    
    private func commonInit() {
        self.frame = .init(0, 0, 130, 42)
        self.borderColor = UIColor(.mainColor)
        self.borderWidth = 1
        self.cornerRadius = 5
        
        self.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        self.setTitleColor(UIColor(.mainColor), for: .normal)
        self.setTitle("종합성적표 확인", for: .normal)
    }
}
