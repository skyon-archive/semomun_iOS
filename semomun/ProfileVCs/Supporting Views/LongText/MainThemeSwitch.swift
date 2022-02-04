//
//  MainThemeSwitch.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class MainThemeSwitch: UIControl {
    private let onTintColor = UIColor(named: "mainColor")
    private let offTintColor = UIColor.lightGray
    
    private let animationDuration = 0.4
    
    private let thumbView = UIView(frame: .zero)
    private let thumbColor = UIColor.white
    
    private var isAnimating = false
    private var isOn = false
    private var onPoint = CGPoint.zero
    private var offPoint = CGPoint.zero
    
    private var action: ((Bool) -> ())?
    
    func setup(_ action: @escaping (Bool) -> ()) {
        self.thumbView.backgroundColor = self.thumbColor
        self.thumbView.isUserInteractionEnabled = false
        self.addSubview(self.thumbView)
        let buttonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.toggleButton()
            self.action?(self.isOn)
        }
        self.addAction(buttonAction, for: .touchUpInside)
        self.action = action
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.isAnimating == false else { return }
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        let thumbSize = CGSize(width: self.bounds.size.height/3*2, height: self.bounds.size.height/3*2)
        let yPos = (self.bounds.size.height - thumbSize.height) / 2
        
        self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - 5, y: yPos)
        self.offPoint = CGPoint(x: 5, y: yPos)
        
        self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
        
        self.thumbView.layer.cornerRadius = thumbSize.width / 2
    }
    
    func toggleButton() {
        self.isOn.toggle()
        self.isAnimating = true
        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: { [weak self] in
            guard let isOn = self?.isOn, let thumbViewXPos = isOn ? self?.onPoint.x : self?.offPoint.x else { return }
            self?.thumbView.frame.origin.x = thumbViewXPos
            self?.backgroundColor = isOn ? self?.onTintColor : self?.offTintColor
        }) { _ in
            self.isAnimating = false
            self.sendActions(for: .valueChanged)
        }
    }
}
