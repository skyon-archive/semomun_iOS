//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class BookshelfVC: UIViewController {
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var navigationTitleView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
    }
}
