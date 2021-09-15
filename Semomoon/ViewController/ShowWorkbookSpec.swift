//
//  ShowWorkbookSpec.swift
//  Semomoon
//
//  Created by qwer on 2021/09/15.
//

import UIKit
import CoreData

class ShowWorkbookSpec: UIViewController {
    
    @IBOutlet weak var wid: UILabel!
    var wid_data: Int = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        guard let entity = NSEntityDescription.entity(forEntityName: "Preview_Core", in: context) else {
            print("error"); return }
//        let preview_core = Preview_Core(entity: entity, context: context, preview_real: preview_real)
        let preview_core = Preview_Core(context: context)
        preview_core.setValue(preview_real.preview.wid, forKey: "wid")
        preview_core.setValue(preview_real.preview.title, forKey: "title")
        preview_core.setValue(preview_real.imageData, forKey: "image")
        do {
            try context.save()
//            try context.fetch(Preview_Core.fetchRequest())
            print("save complete")
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}
