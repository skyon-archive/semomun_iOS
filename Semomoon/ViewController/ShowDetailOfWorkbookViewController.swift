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
    var selectedPreview: Preview!
    var loadedImageData: Data!
//    var loadedImage: UIImage!
    
    let dbUrlString = "https://96d3-118-36-227-50.ngrok.io/workbooks/preview"
    let imageUrlString = "https://96d3-118-36-227-50.ngrok.io/images/workbook/64x64/"
    
    override func viewDidLoad() {
        wid.text = "\(selectedPreview.wid)"
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
//        let tempWorkBook = Workbook(wid: 0, title: "ASdf", image: "////.png", year: 1, month: 2, price: 1, detail: "123", sales: 1, publisher: "123", category: "!23", subject: "!23")
        let tempWorkBook = Workbook(wid: 0, title: "ASdf", year: 1, month: 2, price: 1, detail: "121", image: "sdf", sales: 1, publisher: "1212", category: "모의고사", subject: "국어", grade: 1, sections: [])
        
        let preview_core = Preview_Core(context: CoreDataManager.shared.context)
        preview_core.setValues(preview: selectedPreview, subject: tempWorkBook.subject)
        preview_core.setValue(loadedImageData, forKey: "image")
        do {
            try CoreDataManager.shared.appDelegate.saveContext()
            print("save complete")
            NotificationCenter.default.post(name: ShowDetailOfWorkbookViewController.refresh, object: self)
            self.dismiss(animated: true, completion: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func loadPreviewFromDB(query: String) {
        guard let dbURL = URL(string: dbUrlString) else {
            print("Error of url")
            return
        }
        do {
            guard let jsonData = try String(contentsOf: dbURL).data(using: .utf8) else {
                print("Error of jsonData")
                return
            }
//            let getJsonData: SearchPreview = try! JSONDecoder().decode(SearchPreview.self, from: jsonData)
//            loadedPreviews = getJsonData.workbooks
//            preview.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
