//
//  ShowWorkbookSpec.swift
//  Semomoon
//
//  Created by qwer on 2021/09/15.
//

import UIKit
import CoreData

class ShowDetailOfWorkbookViewController: UIViewController {
    static let refresh = Notification.Name("refresh")
    
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var wid: UILabel!
    var selectedPreview: PreviewOfDB!
    
    let dbUrlString = "https://ccee-118-36-227-50.ngrok.io/workbooks/preview/"
    let imageUrlString = "https://ccee-118-36-227-50.ngrok.io/images/workbook/64x64/"
    
    override func viewDidLoad() {
//        wid.text = "\(selectedPreview.wid)"
        
        testImage.layer.shadowOffset = CGSize(width: 5, height: 5)
        testImage.layer.shadowOpacity = 0.7
        testImage.layer.shadowRadius = 5
        testImage.layer.shadowColor = UIColor.gray.cgColor
        testImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
        
        
    }
}
