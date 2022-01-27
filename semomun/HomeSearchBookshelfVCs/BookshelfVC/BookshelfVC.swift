//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import AVFoundation

class BookshelfVC: UIViewController {
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var bookCountLabel: UILabel!
    @IBOutlet weak var refreshBT: UIButton!
    @IBOutlet weak var sortSelector: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
        self.configureUI()
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.spinAnimation()
    }
}

extension BookshelfVC {
    private func configureUI() {
        self.sortSelector.layer.borderWidth = 1
        self.sortSelector.layer.borderColor = UIColor.lightGray.cgColor
        self.sortSelector.clipsToBounds = true
        self.sortSelector.cornerRadius = 3
    }
    
    private func spinAnimation() {
        UIView.animate(withDuration: 1) {
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.refreshBT.transform = CGAffineTransform.identity
        }
    }
}
