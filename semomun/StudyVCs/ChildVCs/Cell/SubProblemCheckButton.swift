//
//  SubProblemCheckButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/20.
//
import UIKit

protocol SubProblemCheckObservable: AnyObject {
    func checkButton(index: Int)
}

class SubProblemCheckButton: UIButton {
    static let korLabels = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ"]
    static let EngLabels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    static let engLabels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]

    convenience init(index: Int, delegate: SubProblemCheckObservable) {
        self.init(frame: CGRect(0, 0, 30, 30))
        self.commonInit(index: index, delegate: delegate)
    }

    private func commonInit(index: Int, delegate: SubProblemCheckObservable) {
        self.backgroundColor = .white
        
        self.borderWidth = 1
        self.layer.borderColor = UIColor(.deepMint)?.cgColor
        self.layer.cornerRadius = 15
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.setTitleColor(UIColor(.deepMint), for: .normal)
        self.setTitle(Self.korLabels[index], for: .normal)
        
        self.tag = index
        
        self.addAction(UIAction(handler: { _ in
            delegate.checkButton(index: index)
        }), for: .touchUpInside)
    }

    func select() {
        self.backgroundColor = UIColor(.deepMint)
        self.setTitleColor(.white, for: .normal)
        self.layoutIfNeeded()
    }

    func deselect() {
        self.backgroundColor = .white
        self.setTitleColor(UIColor(.deepMint), for: .normal)
    }
}
