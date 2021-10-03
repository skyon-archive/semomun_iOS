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
    
    @IBOutlet weak var wid: UILabel!
    var selectedPreview: PreviewOfDB!
    
    let dbUrlString = "https://ccee-118-36-227-50.ngrok.io/workbooks/preview/"
    let imageUrlString = "https://ccee-118-36-227-50.ngrok.io/images/workbook/64x64/"
    
    override func viewDidLoad() {
        wid.text = "\(selectedPreview.wid)"
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
        
        
    }
    
    
}
