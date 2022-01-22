//
//  ExplanationVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class ExplanationVC: UIViewController {
    static let identifier = "ExplanationVC"
    static let storyboardName = "Study"

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var explanationImageView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var explanationImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureImageView()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ExplanationVC {
    func configureImageView() {
        guard let image = self.explanationImage else { return }
        let width = scrollView.frame.width
        let height = image.size.height*(width/image.size.width)
        
        self.explanationImageView.image = image
        self.explanationImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.imageHeight.constant = height
    }
}

