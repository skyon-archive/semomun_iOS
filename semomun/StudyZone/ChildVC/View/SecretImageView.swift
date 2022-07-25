//
//  SecretImageView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/23.
//

import UIKit

final class SecretImageView: UIView {
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
    private let borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        return view
    }()
    
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
            self.borderView.frame = .init(-1, -1, frame.width + 2, frame.height + 2)
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
        self.addSubview(self.borderView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
