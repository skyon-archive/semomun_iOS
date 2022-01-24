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
    private var activateToggle = false
    
    
    @IBOutlet weak var frame: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frame.layer.cornerRadius = 15

        self.frame.layer.shadowColor = UIColor.gray.cgColor
        self.frame.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.frame.layer.shadowOpacity = 0.4
        self.frame.layer.shadowRadius = 4
        
        self.textView.layer.cornerRadius = 15
        self.textView.textContainerInset = UIEdgeInsets(top: 67, left: 105, bottom: 67, right: 105)
        
        if activateToggle {
            self.label.isHidden = false
            let toggle = MainThemeSwitch() // 여기서의 frame값은 무시됨. 
            toggle.translatesAutoresizingMaskIntoConstraints = false
            toggle.setupUI()
            self.view.addSubview(toggle)
            NSLayoutConstraint.activate([
                toggle.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
                toggle.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                toggle.widthAnchor.constraint(equalToConstant: 50),
                toggle.heightAnchor.constraint(equalToConstant: 25),
            ])
            self.view.bringSubviewToFront(label)
            self.view.bringSubviewToFront(toggle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.text = self.text
        self.navigationItem.title = self.navigationBarTitle
    }
}

extension LongTextVC {
    func configureUI(title: String, text: String, marketingInfo: Bool = false) {
        self.navigationBarTitle = title
        self.text = text
        self.activateToggle = marketingInfo
    }
}
