//
//  ExplanationView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/06.
//

import UIKit

protocol ExplanationRemovable: AnyObject {
    func closeExplanation()
}

final class ExplanationView: UIView {
    private weak var delegate: ExplanationRemovable?
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let xmarkImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(.xmark, withConfiguration: largeConfig)
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.xmarkImage, for: .normal)
        button.tintColor = .black
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.closeExplanation()
        }), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureUI()
        self.configureLayout()
        self.configureScrollView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame.size = self.frame.size
        self.adjustLayout()
    }
    
    func configureDelegate(to delegate: ExplanationRemovable) {
        self.delegate = delegate
    }
    
    func configureImage(to image: UIImage?) {
        guard let image = image else { return }
        self.imageView.image = image
        self.adjustLayout()
    }
    
    /// FormZero에서 사용
    func updateFrame(contentSize: CGSize, topHeight: CGFloat) {
        if UIWindow.isLandscape {
            let newSize = CGSize(width: contentSize.width/2, height: contentSize.height)
            self.frame = .init(newSize.width, 0, newSize.width, newSize.height)
        } else {
            let newSize = CGSize(width: contentSize.width, height: (contentSize.height - topHeight)/2)
            self.frame = .init(0, newSize.height + topHeight, newSize.width, newSize.height)
        }
    }
    
    /// FormOne에서 사용
    func updateFrame(formOneContentSize contentSize: CGSize) {
        if UIWindow.isLandscape {
            self.frame = .init(0, 0, contentSize.width/2, contentSize.height)
        } else {
            self.frame = .init(0, contentSize.height/2, contentSize.width, contentSize.height/2)
        }
    }
    
    /// FormTwo 에서 사용
    func updateFrame(formTwoContentSize contentSize: CGSize) {
        if UIWindow.isLandscape {
            let marginBetweenView: CGFloat = 26
            self.frame = .init(origin: .zero, size: .init((contentSize.width - marginBetweenView)/2, contentSize.height))
        } else {
            let marginBetweenView: CGFloat = 13
            self.frame = .init(origin: .zero, size: .init(contentSize.width, (contentSize.height - marginBetweenView)/2))
        }
    }
}

extension ExplanationView {
    private func configureUI() {
        self.backgroundColor = .white
        self.imageView.backgroundColor = .white
        self.addShadow()
        self.alpha = 0
    }
    
    private func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.addDoubleTabGesture()
    }
    
    private func configureLayout() {
        self.addSubviews(self.scrollView, self.closeButton)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.sendSubviewToBack(self.imageView)
        
        NSLayoutConstraint.activate([
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }
    
    /// CanvasView의 크기가 바뀐 후 이에 맞게 필기/이미지 레이아웃을 수정
    private func adjustLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint) {
        guard let image = self.imageView.image else {
            assertionFailure("CanvasView의 크기를 구할 이미지 정보 없음")
            return
        }
        
        let ratio = image.size.height/image.size.width
        self.scrollView.adjustContentLayout(previousContentOffset: previousContentOffset, contentRatio: ratio)
        
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.scrollView.contentSize
    }
    
    /// action 전/후 레이아웃 변경을 저장해주는 편의 함수
    private func adjustLayout(_ action: (() -> ())? = nil) {
        let previousCanvasSize = self.scrollView.frame.size
        let previousContentOffset = self.scrollView.contentOffset
        action?()
        self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
    }
}

extension ExplanationView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}