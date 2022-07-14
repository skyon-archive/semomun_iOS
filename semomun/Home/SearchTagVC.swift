//
//  SearchTagVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import UIKit
import Combine

final class SearchTagVC: UIViewController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.background)
        view.layer.cornerRadius = .cornerRadius24
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 472),
            view.heightAnchor.constraint(equalToConstant: 499)
        ])
        
        return view
    }()
    private let contentFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.white)
        
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading3
        label.textColor = UIColor.getSemomunColor(.black)
        label.text = "나의 태그"
        
        return label
    }()
    private let searchBarTextField = SearchBarTextField()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.configureBackgroundLayout()
        self.configureContentFrameViewLayout()
        self.configureLabelLayout()
        self.configureSearchBarTextFieldLayout()
    }
}

extension SearchTagVC {
    private func configureBackgroundLayout() {
        self.view.addSubview(self.backgroundView)
        NSLayoutConstraint.activate([
            self.backgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.backgroundView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    private func configureContentFrameViewLayout() {
        self.backgroundView.addSubview(self.contentFrameView)
        NSLayoutConstraint.activate([
            self.contentFrameView.widthAnchor.constraint(equalTo: self.backgroundView.widthAnchor),
            self.contentFrameView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor),
            self.contentFrameView.heightAnchor.constraint(equalToConstant: 339)
        ])
    }
    private func configureLabelLayout() {
        self.view.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 24),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 24),
        ])
    }
    private func configureSearchBarTextFieldLayout() {
        self.view.addSubview(self.searchBarTextField)
        NSLayoutConstraint.activate([
            self.searchBarTextField.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.searchBarTextField.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.searchBarTextField.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -24),
        ])
    }
}





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
