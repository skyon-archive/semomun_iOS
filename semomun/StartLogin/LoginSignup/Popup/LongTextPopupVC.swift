//
//  LongTextPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

final class LongTextPopupVC: UIViewController {
    static let identifier = "LongTextPopupVC"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .black)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
