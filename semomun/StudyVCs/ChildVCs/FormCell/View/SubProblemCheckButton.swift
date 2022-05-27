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
    
    private var size: CGFloat = 32

    convenience init(size: CGFloat, index: Int, delegate: SubProblemCheckObservable) {
        self.init(frame: CGRect(0, 0, 32, 32))
        self.commonInit(size: size, index: index, delegate: delegate)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.size, height: self.size)
    }

    private func commonInit(size: CGFloat, index: Int, delegate: SubProblemCheckObservable) {
        self.size = size
        
        self.backgroundColor = .clear
        
        self.borderWidth = 1
        self.layer.borderColor = UIColor(.deepMint)?.cgColor
        self.layer.cornerRadius = size/2
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
        self.backgroundColor = .clear
        self.setTitleColor(UIColor(.deepMint), for: .normal)
    }
    
    func wrong() {
        self.layer.borderColor = UIColor(.munRedColor)?.cgColor
        self.setTitleColor(UIColor(.munRedColor) ?? .red, for: .normal)
        self.backgroundColor = .clear
    }
}
