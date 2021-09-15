//
//  ShowWorkbookSpec.swift
//  Semomoon
//
//  Created by qwer on 2021/09/15.
//

import UIKit

class ShowWorkbookSpec: UIViewController {
    
    @IBOutlet weak var wid: UILabel!
    var wid_data: Int = 0
    override func viewDidLoad() {
        wid.text = "\(wid_data)"
    }
    @IBAction func addWorkbook(_ sender: Any) {
        // local -> DB (wid)
        // DB -> local (Workbook)
        let tempWorkBook = Workbook(wid: 0, title: "ASdf", image: 1, year: 1, month: 2, price: 1, detail: "123", sales: 1, publisher: "123", category: "!23", subject: "!23")
        // save to coreData
        let workBook_real = Workbook_Real(workBook: tempWorkBook)
        let preview_real = tempWorkBook.preview()
        // preview_real -> coreData
        
    }
}
