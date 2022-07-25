//
//  SlideSectionContentsView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/22.
//

import UIKit

protocol StudyContentsSlideDelegate: AnyObject {
    func closeSlideView()
}

final class SlideSectionContentsView: UIView {
    /* public */
    static let width = CGFloat(320)
    enum Mode {
        case contents
        case bookmark
    }
    var mode: Mode = .contents {
        didSet {
            switch mode {
            case .contents:
                self.contentsModeButton.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                self.contentsUnderline.alpha = 1
                self.bookmarkModeButton.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                self.bookmakrUnderline.alpha = 0
            case .bookmark:
                self.contentsModeButton.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                self.contentsUnderline.alpha = 0
                self.bookmarkModeButton.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                self.bookmakrUnderline.alpha = 1
            }
            self.problemsCollectionView.reloadData()
        }
    }
    /* private */
    private lazy var contentsModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.heading4
        button.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
        button.setTitle("목차", for: .normal)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.mode = .contents
        }), for: .touchUpInside)
        
        return button
    }()
    private lazy var bookmarkModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.heading4
        button.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
        button.setTitle("북마크", for: .normal)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 42),
            button.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.mode = .bookmark
        }), for: .touchUpInside)
        
        return button
    }()
    private lazy var modeButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.contentsModeButton, self.bookmarkModeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    private var contentsUnderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.blueRegular)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 3)
        ])
        view.alpha = 1
        return view
    }()
    private var bookmakrUnderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.blueRegular)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 3)
        ])
        view.alpha = 0
        return view
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .black)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        button .addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.closeSlideView()
        }), for: .touchUpInside)
        
        return button
    }()
    private var contentFrameview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configureTopCorner(radius: CGFloat.cornerRadius16)
        view.backgroundColor = UIColor.getSemomunColor(.white)
        return view
    }()
    private var workbookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading4
        label.textColor = UIColor.getSemomunColor(.black)
        label.textAlignment = .left
        return label
    }()
    private var underlineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.border)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return view
    }()
    private var backToSectionListButton: UIButton = { // 추후 사용될 버튼
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20)
        ])
        return button
    }()
    private var sectionNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading4
        label.textColor = UIColor.getSemomunColor(.black)
        label.textAlignment = .left
        return label
    }()
    private var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.largeStyleParagraph
        label.textColor = UIColor.getSemomunColor(.darkGray)
        label.textAlignment = .left
        return label
    }()
    private var sectionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    private var problemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(40, 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private weak var delegate: StudyContentsSlideDelegate?
    
    private func commonInit(workbookTitle: String, sectionNum: Int, sectionTitle: String) {
        self.workbookTitleLabel.text = workbookTitle
        self.sectionNumLabel.text = String(format: "%02d", sectionNum)
        self.sectionTitleLabel.text = sectionTitle
    }
}

// MARK: Public functions
extension SlideSectionContentsView {
    func configure(workbookTitle: String, sectionNum: Int, sectionTitle: String, delegate: StudyContentsSlideDelegate) {
        self.delegate = delegate
        self.commonInit(workbookTitle: workbookTitle, sectionNum: sectionNum, sectionTitle: sectionTitle)
        self.configureLayout()
        self.configureCollectionView()
    }
    
    func configureDelegate(_ delegate: (UICollectionViewDelegate & UICollectionViewDataSource)) {
        self.problemsCollectionView.delegate = delegate
        self.problemsCollectionView.dataSource = delegate
    }
    
    func reload() {
        self.problemsCollectionView.reloadData()
    }
}

// MARK: Private configure functions
extension SlideSectionContentsView {
    private func configureLayout() {
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: SlideSectionContentsView.width)
        ])
        
        self.addSubviews(self.modeButtonsStackView)
        NSLayoutConstraint.activate([
            self.modeButtonsStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.modeButtonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
        
        self.contentsModeButton.addSubviews(self.contentsUnderline)
        NSLayoutConstraint.activate([
            self.contentsUnderline.bottomAnchor.constraint(equalTo: self.contentsModeButton.bottomAnchor),
            self.contentsUnderline.leadingAnchor.constraint(equalTo: self.contentsModeButton.leadingAnchor),
            self.contentsUnderline.trailingAnchor.constraint(equalTo: self.contentsModeButton.trailingAnchor)
        ])
        
        self.bookmarkModeButton.addSubviews(self.bookmakrUnderline)
        NSLayoutConstraint.activate([
            self.bookmakrUnderline.bottomAnchor.constraint(equalTo: self.bookmarkModeButton.bottomAnchor),
            self.bookmakrUnderline.leadingAnchor.constraint(equalTo: self.bookmarkModeButton.leadingAnchor),
            self.bookmakrUnderline.trailingAnchor.constraint(equalTo: self.bookmarkModeButton.trailingAnchor)
        ])
        
        self.addSubview(self.closeButton)
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 9),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
        
        self.addSubview(self.contentFrameview)
        NSLayoutConstraint.activate([
            self.contentFrameview.topAnchor.constraint(equalTo: self.topAnchor, constant: 42),
            self.contentFrameview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentFrameview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentFrameview.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.contentFrameview.addSubview(self.workbookTitleLabel)
        NSLayoutConstraint.activate([
            self.workbookTitleLabel.topAnchor.constraint(equalTo: self.contentFrameview.topAnchor, constant: 16),
            self.workbookTitleLabel.leadingAnchor.constraint(equalTo: self.contentFrameview.leadingAnchor, constant: 16),
            self.workbookTitleLabel.trailingAnchor.constraint(equalTo: self.contentFrameview.trailingAnchor, constant: -16)
        ])
        
        self.contentFrameview.addSubview(self.underlineView)
        NSLayoutConstraint.activate([
            self.underlineView.topAnchor.constraint(equalTo: self.workbookTitleLabel.bottomAnchor, constant: 16),
            self.underlineView.leadingAnchor.constraint(equalTo: self.workbookTitleLabel.leadingAnchor),
            self.underlineView.trailingAnchor.constraint(equalTo: self.workbookTitleLabel.trailingAnchor)
        ])
        
        self.sectionStackView.addArrangedSubview(self.backToSectionListButton)
        self.sectionStackView.addArrangedSubview(self.sectionNumLabel)
        self.sectionStackView.addArrangedSubview(self.sectionTitleLabel)
        self.contentFrameview.addSubview(self.sectionStackView)
        NSLayoutConstraint.activate([
            self.sectionStackView.topAnchor.constraint(equalTo: self.underlineView.bottomAnchor, constant: 16),
            self.sectionStackView.leadingAnchor.constraint(equalTo: self.underlineView.leadingAnchor),
            self.sectionStackView.trailingAnchor.constraint(equalTo: self.underlineView.trailingAnchor)
        ])
        
        self.contentFrameview.addSubviews(self.problemsCollectionView)
        NSLayoutConstraint.activate([
            self.problemsCollectionView.topAnchor.constraint(equalTo: self.sectionStackView.bottomAnchor, constant: 16),
            self.problemsCollectionView.leadingAnchor.constraint(equalTo: self.contentFrameview.leadingAnchor, constant: 16),
            self.problemsCollectionView.trailingAnchor.constraint(equalTo: self.contentFrameview.trailingAnchor, constant: -16),
            self.problemsCollectionView.bottomAnchor.constraint(equalTo: self.contentFrameview.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureCollectionView() {
        let problemCellNib = UINib(nibName: ProblemCell.identifier, bundle: nil)
        self.problemsCollectionView.register(problemCellNib, forCellWithReuseIdentifier: ProblemCell.identifier)
    }
}
