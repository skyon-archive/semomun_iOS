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

    convenience init(size: CGFloat, fontSize: CGFloat, index: Int, delegate: SubProblemCheckObservable) {
        self.init(frame: CGRect(0, 0, 32, 32))
        self.commonInit(size: size, fontSize: fontSize, index: index, delegate: delegate)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.size, height: self.size)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor(.deepMint)
                self.setTitleColor(.white, for: .normal)
            } else {
                self.backgroundColor = .clear
                self.setTitleColor(UIColor(.deepMint), for: .normal)
            }
        }
    }

    private func commonInit(size: CGFloat, fontSize: CGFloat, index: Int, delegate: SubProblemCheckObservable) {
        self.size = size
        
        self.backgroundColor = .clear
        
        self.borderWidth = 1
        self.layer.borderColor = UIColor(.deepMint)?.cgColor
        self.layer.cornerRadius = size/2
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        self.setTitleColor(UIColor(.deepMint), for: .normal)
        self.setTitle(Self.korLabels[index], for: .normal)
        
        self.tag = index
        
        self.addAction(UIAction(handler: { _ in
            delegate.checkButton(index: index)
        }), for: .touchUpInside)
    }
    
    func setWrongUI() {
        self.layer.borderColor = UIColor(.munRedColor)?.cgColor
        self.setTitleColor(UIColor(.munRedColor) ?? .red, for: .normal)
        self.backgroundColor = .clear
    }
}
