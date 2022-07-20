//
//  HomeAdCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import UIKit
import Kingfisher

final class HomeAdCell: UICollectionViewCell {
    static let identifier = "HomeAdCell"
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // loadingBookcover가 단색 이미지임을 가정
        view.image = UIImage(.loadingBookcover)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.cornerRadius = .cornerRadius16
        
        return view
    }()
    private var url: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
        ])
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openURL)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(.loadingBookcover)
    }
    
    func configureContent(imageURL: URL, url: URL) {
        self.url = url
        self.imageView.kf.setImage(with: imageURL)
    }
    
    @objc private func openURL() {
        if let url = self.url {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
