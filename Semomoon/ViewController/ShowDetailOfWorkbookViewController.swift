//
//  ShowWorkbookSpec.swift
//  Semomoon
//
//  Created by qwer on 2021/09/15.
//

import UIKit
import CoreData

class ShowDetailOfWorkbookViewController: UIViewController {
    
    @IBOutlet weak var wid: UILabel!
    var selectedPreview: Preview_Core!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        wid.text = "\(selectedPreview.wid)"
    }
    @IBAction func addWorkbook(_ sender: Any) {
        // local -> DB (wid)
        // DB -> local (Workbook)
        let tempWorkBook = Workbook(wid: 0, title: "ASdf", image: Data(), year: 1, month: 2, price: 1, detail: "123", sales: 1, publisher: "123", category: "!23", subject: "!23")
        // save to coreData
        // preview_real -> coreData
//        let preview_core = Preview_Core(entity: entity, context: context, preview_real: preview_real)
        let preview_core = Preview_Core(context: context)
        preview_core.setValue(selectedPreview.wid, forKey: "wid")
        preview_core.setValue(selectedPreview.title, forKey: "title")
        preview_core.setValue(selectedPreview.image, forKey: "image")
        preview_core.setValue(tempWorkBook.subject, forKey: "subject")
        do {
            try context.save()
//            try context.fetch(Preview_Core.fetchRequest())
            print("save complete")
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}
