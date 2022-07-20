//
//  WorkbookInfoPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/20.
//

import UIKit

final class WorkbookInfoPopupVC: UIViewController {
    static let identifier = "WorkbookInfoPopupVC"
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publishCompanyLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var workbookInfo: WorkbookInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureData()
    }
    
    private func configureData() {
        guard let info = self.workbookInfo else { return }
        
        self.authorLabel.text = info.author
        self.publishCompanyLabel.text = info.publisher
        self.publishDateLabel.text = info.releaseDate
        if info.isbn != "" {
            self.isbnLabel.text = info.isbn
        }
        if info.price != 0 {
            self.priceLabel.text = "\(info.price.withComma)원"
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
