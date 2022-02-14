//
//  SearchTagVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import UIKit
import Combine

final class SearchTagVC: UIViewController {
    static let identifier = "SearchTagVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var selectedTags: UICollectionView!
    @IBOutlet weak var searchTagResults: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchTag(_ sender: Any) {
        
    }
}
