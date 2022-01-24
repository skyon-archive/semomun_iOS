//
//  LongTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class LongTextVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "LongTextVC"
    
    private var navigationBarTitle: String?
    private var text: String?
    
    
    @IBOutlet weak var frame: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frame.layer.cornerRadius = 15

        // shadow
        self.frame.layer.shadowColor = UIColor.gray.cgColor
        self.frame.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.frame.layer.shadowOpacity = 0.4
        self.frame.layer.shadowRadius = 4
        
        self.textView.layer.cornerRadius = 15
        self.textView.textContainerInset = UIEdgeInsets(top: 29, left: 103, bottom: 29, right: 103)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.text = self.text
        self.navigationItem.title = self.navigationBarTitle
    }
}

extension LongTextVC {
    func configureUI(title: String, text: String) {
        self.navigationBarTitle = title
        self.text = text
    }
}
