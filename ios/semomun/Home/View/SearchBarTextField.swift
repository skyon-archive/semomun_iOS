//
//  SearchBarTextField.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/14.
//

import UIKit

final class SearchBarTextField: UITextField {
    let commonInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.layer.cornerRadius = .cornerRadius12
        self.layer.cornerCurve = .continuous
        self.font = .largeStyleParagraph
        self.attributedPlaceholder = NSAttributedString(string: "태그, 제목, 출판사", attributes: [
            .foregroundColor: UIColor.getSemomunColor(.lightGray),
            .font: UIFont.largeStyleParagraph
        ])
        self.textColor = UIColor.getSemomunColor(.black)
        self.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let searchImage = UIImage(.searchOutline)
        let searchImageView = UIImageView(image: searchImage)
        searchImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchImageView.widthAnchor.constraint(equalToConstant: 24),
            searchImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        self.leftView = searchImageView
        self.leftViewMode = .always
        
        let clearButtonImage = UIImage(.xOutline)
        let clearButton = UIButton(type: .custom)
        clearButton.isHidden = true
        clearButton.setImage(clearButtonImage, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        self.rightView = clearButton
        self.rightViewMode = .always
        
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.displayClearButtonIfNeeded), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: self.commonInset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: self.commonInset)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftViewRect = super.leftViewRect(forBounds: bounds)
        leftViewRect.origin.x += 8
        return leftViewRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x -= 8
        return rightViewRect
    }
    
    @objc private func displayClearButtonIfNeeded() {
        self.rightView?.isHidden = (self.text?.isEmpty) ?? true
    }
    
    @objc private func clear(sender: AnyObject) {
        self.text = ""
        self.sendActions(for: .editingChanged)
    }
}
