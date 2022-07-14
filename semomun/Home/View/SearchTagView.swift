//
//  SearchTagView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/14.
//

import UIKit

class SearchTagView: UIView {
    /* public */
    enum Mode {
        // 하단 버튼이 '취소'/'적용'으로 구성됨
        case home
        // 하단 버튼이 '다음'으로 구성됨
        case login
    }
    let searchBarTextField = SearchBarTextField()
    let searchTagCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let nib = UINib(nibName: RemoveableTagCell.identifier, bundle: nil)
        view.register(nib, forCellWithReuseIdentifier: RemoveableTagCell.identifier)
        
        return view
    }()
    let searchResultCollectionView: UICollectionView = {
        let flowLayout = TagsLayout()
        flowLayout.minimumInteritemSpacing = 4
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 236).isActive = true
        
        let nib = UINib(nibName: TagCell.identifier, bundle: nil)
        view.register(nib, forCellWithReuseIdentifier: TagCell.identifier)
        
        return view
    }()
    lazy var cancelButton: UIButton = {
        let button = self.makeBottomButton()
        button.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
        button.setTitle("취소", for: .normal)
        button.backgroundColor = UIColor.getSemomunColor(.background)
        button.borderColor = UIColor.getSemomunColor(.border)
        button.borderWidth = 1
        return button
    }()
    lazy var confirmButton: UIButton = {
        let button = self.makeBottomButton()
        button.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        button.backgroundColor = UIColor.getSemomunColor(.blueRegular)
        return button
    }()
    /* private */
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.background)
        view.layer.cornerRadius = .cornerRadius24
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 472),
            view.heightAnchor.constraint(equalToConstant: 521)
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
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = UIColor.getSemomunColor(.darkGray)
        label.text = "원하는 분야를 10개 이내로 선택해주세요."
        
        return label
    }()
    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        
        return view
    }()
    
    init(mode: Mode) {
        super.init(frame: .zero)
        self.configureBackgroundLayout()
        self.configureContentFrameViewLayout()
        self.configureLabelLayout()
        self.configureSearchBarTextFieldLayout()
        self.configureSearchTagCollectionViewLayout()
        self.configureSearchResultCollectionViewLayout()
        self.configureButtonStackViewLayout()
        switch mode {
        case .home:
            self.buttonStackView.addArrangedSubview(self.cancelButton)
            self.buttonStackView.addArrangedSubview(self.confirmButton)
            self.confirmButton.setTitle("적용", for: .normal)
        case .login:
            self.buttonStackView.addArrangedSubview(self.confirmButton)
            self.confirmButton.setTitle("다음", for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enableConfirmButton() {
        self.confirmButton.isEnabled = true
        self.confirmButton.backgroundColor = UIColor.getSemomunColor(.blueRegular)
    }
    
    func disableConfirmButton() {
        self.confirmButton.isEnabled = false
        self.confirmButton.backgroundColor = UIColor.getSemomunColor(.lightGray)
    }
    
    func updateSearchResultTransparent() {
        self.searchResultCollectionView.layer.opacity = 0.2
    }
    
    func updateSearchResultOpaque() {
        self.searchResultCollectionView.layer.opacity = 1
    }
}

// MARK: Configure Layout
extension SearchTagView {
    private func configureBackgroundLayout() {
        self.addSubview(self.backgroundView)
        NSLayoutConstraint.activate([
            self.backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    private func configureContentFrameViewLayout() {
        self.backgroundView.addSubview(self.contentFrameView)
        NSLayoutConstraint.activate([
            self.contentFrameView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.contentFrameView.widthAnchor.constraint(equalTo: self.backgroundView.widthAnchor),
            self.contentFrameView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor),
            self.contentFrameView.heightAnchor.constraint(equalToConstant: 339)
        ])
    }
    private func configureLabelLayout() {
        self.addSubviews(self.titleLabel, self.descriptionLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 24),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 24),
            
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
        ])
    }
    private func configureSearchBarTextFieldLayout() {
        self.addSubview(self.searchBarTextField)
        NSLayoutConstraint.activate([
            self.searchBarTextField.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 16),
            self.searchBarTextField.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.searchBarTextField.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -24),
        ])
    }
    private func configureSearchTagCollectionViewLayout() {
        self.addSubview(self.searchTagCollectionView)
        NSLayoutConstraint.activate([
            self.searchTagCollectionView.topAnchor.constraint(equalTo: self.searchBarTextField.bottomAnchor, constant: 12),
            self.searchTagCollectionView.leadingAnchor.constraint(equalTo: self.contentFrameView.leadingAnchor),
            self.searchTagCollectionView.trailingAnchor.constraint(equalTo: self.contentFrameView.trailingAnchor),
        ])
    }
    private func configureSearchResultCollectionViewLayout() {
        self.contentFrameView.addSubview(self.searchResultCollectionView)
        NSLayoutConstraint.activate([
            self.searchResultCollectionView.topAnchor.constraint(equalTo: self.contentFrameView.topAnchor, constant: 24),
            self.searchResultCollectionView.leadingAnchor.constraint(equalTo: self.contentFrameView.leadingAnchor, constant: 24),
            self.searchResultCollectionView.trailingAnchor.constraint(equalTo: self.contentFrameView.trailingAnchor, constant: -24),
        ])
    }
    
    private func configureButtonStackViewLayout() {
        self.contentFrameView.addSubview(self.buttonStackView)
        NSLayoutConstraint.activate([
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.searchResultCollectionView.leadingAnchor),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.searchResultCollectionView.trailingAnchor),
            self.buttonStackView.topAnchor.constraint(equalTo: self.searchResultCollectionView.bottomAnchor, constant: 12),
            self.buttonStackView.heightAnchor.constraint(equalToConstant: 43)
        ])
    }
}

extension SearchTagView {
    private func makeBottomButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.heading4
        button.layer.cornerRadius = .cornerRadius12
        button.layer.cornerCurve = .continuous
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 208),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        return button
    }
}
