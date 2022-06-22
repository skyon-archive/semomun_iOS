//
//  NibLoadable.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/22.
//

import UIKit

/// Xib 파일로 만들어진 뷰를 UIView 클래스에서 가져와 쓸 수 있게 해주는 프로토콜
protocol NibLoadable {
    // MARK: extension에 기본값이 있어 xib 파일의 이름이 이 프로토콜을 채택하는 클래스의 이름과 같다면 따로 구현할 필요 없음.
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self)
    }
    
    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    static private var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }
}
