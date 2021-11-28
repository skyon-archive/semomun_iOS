//
//  CategoryViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/11/28.
//

import UIKit

final class CategoryViewController: UIViewController {
    enum Identifier {
        static let controller = "CategoryViewController"
        static let segue = "CategorySegue"
    }

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
