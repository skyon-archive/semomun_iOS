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
        guard let DBDatas = loadSidsFromDB(wid: selectedPreview.wid, query: "query") else { return }
        let loadedWorkbook = DBDatas.0
        let sids = DBDatas.1
        
        let preview_core = Preview_Core(context: CoreDataManager.shared.context)
        preview_core.setValues(preview: selectedPreview, subject: loadedWorkbook.subject, sids: sids)
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
    
    func loadSidsFromDB(wid: Int, query: String) -> (Workbook, [Int])? {
        guard let dbURL = URL(string: query) else {
            print("Error of url")
            return nil
        }
        do {
            guard let jsonData = try String(contentsOf: dbURL).data(using: .utf8) else {
                print("Error of jsonData")
                return nil
            }
            let getJsonData: Workbook = try! JSONDecoder().decode(Workbook.self, from: jsonData)
            // 지금은 sid 값들만 추출
            let sections = getJsonData.sections
            var sids: [Int] = []
            sections.forEach { sids.append($0.sid) }
            return (getJsonData, sids)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}
