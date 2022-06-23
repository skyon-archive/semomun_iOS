//
//  SecretImageView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/23.
//

import UIKit

class SecretImageView: UIView {
    private let preventCapture: Bool
    private let hiddenView: UIView = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        let hiddenView = textField.layer.sublayers?.first?.delegate as! UIView
        hiddenView.subviews.forEach { $0.removeFromSuperview() }
        hiddenView.translatesAutoresizingMaskIntoConstraints = false
        return hiddenView
    }()
    private let imageView = UIImageView()
    
    var image: UIImage? {
        get { return self.imageView.image }
        set { self.imageView.image = newValue }
    }
    
    override var frame: CGRect {
        didSet {
            self.imageView.frame = frame
            if self.preventCapture {
                self.hiddenView.frame = frame
            }
        }
    }
    
    init(preventCapture: Bool = true) {
        self.preventCapture = preventCapture
        super.init(frame: .zero)
        if preventCapture {
            self.addSubview(self.hiddenView)
            self.hiddenView.addSubview(self.imageView)
        } else {
            self.addSubview(self.imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
