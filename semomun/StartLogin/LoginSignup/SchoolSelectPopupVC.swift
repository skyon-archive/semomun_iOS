//
//  SchoolSelectPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

protocol SchoolSelectDelegate: AnyObject {
    func selectSchool(to: String)
}

final class SchoolSelectPopupVC: UIViewController {
    static let identifier = "SchoolSelectPopupVC"
    
    @IBOutlet weak var schoolCategoryButton: UIButton!
    @IBOutlet weak var schoolList: UICollectionView!
    private weak var delegate: SchoolSelectDelegate?
    private var schoolName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configureDelegate(_ delegate: SchoolSelectDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        guard let schoolName = schoolName else { return }
        self.delegate?.selectSchool(to: schoolName)
        self.dismiss(animated: true)
    }
}
