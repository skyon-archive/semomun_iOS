//
//  BookshelfDetailHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/07.
//

import UIKit

protocol BookshelfDetailDelegate: AnyObject {
    func refreshWorkbooks()
    func changeOrder(to: DropdownOrderButton.BookshelfOrder)
}

final class BookshelfDetailHeaderView: UICollectionReusableView {
    /* public*/
    static let identifier = "BookshelfDetailHeaderView"
    /* private */
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshIcon: UIImageView!
    private weak var delegate: BookshelfDetailDelegate?
    private lazy var orderButton = DropdownOrderButton(order: .recentRead)
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureOrderButton()
        self.configureRefreshIcon()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.spinAnimation()
        self.delegate?.refreshWorkbooks()
    }
    
    func configure(delegate: BookshelfDetailDelegate, order: DropdownOrderButton.BookshelfOrder) {
        self.delegate = delegate
        self.orderButton.changeOrder(to: order)
    }
}

extension BookshelfDetailHeaderView {
    private func configureOrderButton() {
        self.addSubview(self.orderButton)
        NSLayoutConstraint.activate([
            self.orderButton.centerYAnchor.constraint(equalTo: self.refreshButton.centerYAnchor),
            self.orderButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
        self.orderButton.configureBookshelfMenu(action: { [weak self] order in
            self?.delegate?.changeOrder(to: order)
        })
    }
    
    private func configureRefreshIcon() {
        self.refreshIcon.setSVGTintColor(to: UIColor.getSemomunColor(.black))
    }
    
    private func spinAnimation() {
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.refreshIcon.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
                self.refreshIcon.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
                self.layoutIfNeeded()
            } completion: { _ in
                self.refreshIcon.transform = CGAffineTransform.identity
            }
        }
    }
}
