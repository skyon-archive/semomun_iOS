//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class BookshelfVC: UIViewController {
    /* public */
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet var bookshelfTabButtons: [UIButton]!
    @IBOutlet var bookshelfTabUnderlines: [UIView]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func changeTab(_ sender: UIButton) {
        let index = sender.tag
        self.changeTabUI(index: index)
    }
}

extension BookshelfVC {
    private func changeTabUI(index: Int) {
        UIView.animate(withDuration: 0.1) {
            for idx in 0...2 {
                if idx == index {
                    self.bookshelfTabButtons[idx].setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                    self.bookshelfTabUnderlines[idx].alpha = 1
                } else {
                    self.bookshelfTabButtons[idx].setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                    self.bookshelfTabUnderlines[idx].alpha = 0
                }
            }
        }
    }
}

