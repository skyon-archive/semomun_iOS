//
//  StudyCircleAnswerButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class StudyCircleAnswerButton: UIButton {
    /* pubic */
    var answer: String = ""
    convenience init(answer: String, tag: Int) {
        self.init(frame: CGRect())
        self.answer = answer
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.titleLabel?.font = UIFont.heading5
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 28),
            self.heightAnchor.constraint(equalToConstant: 28)
        ])
        self.setTitle(answer, for: .normal)
        self.tag = tag
        self.deSelect()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.select()
            } else {
                self.deSelect()
            }
        }
    }
    
    private func select() { // 문제 선택시, 채점 이후 틀린 선택문제의 경우
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = UIColor.getSemomunColor(.black)
        self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
    }
    
    private func deSelect() { // 문제 선택 해제시, 정답이 아니며 선택된 문제가 아닌 경우
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
    }
    
    func correct(isSelected: Bool) { // 정답인 경우
        if isSelected {
            self.layer.borderColor = UIColor.clear.cgColor
            self.backgroundColor = UIColor.systemGreen
            self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        } else {
            self.layer.borderColor = UIColor.systemRed.cgColor
            self.backgroundColor = UIColor.getSemomunColor(.white)
            self.setTitleColor(UIColor.systemRed, for: .normal)
        }
    }
    
    func wrong(isSelected: Bool) { // 정답이 아닌 경우
        if isSelected {
            self.layer.borderColor = UIColor.clear.cgColor
            self.backgroundColor = UIColor.getSemomunColor(.lightGray)
            self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        } else {
            self.deSelect()
        }
    }
}
