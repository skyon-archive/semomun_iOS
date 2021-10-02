//
//  selectWorkbookViewController.swift
//  selectWorkbookViewController
//
//  Created by qwer on 2021/09/12.
//

import UIKit
import Kingfisher

class SearchWorkbookViewController: UIViewController {

    @IBOutlet weak var frame: UIView!
    @IBOutlet var selectButtons: [UIButton]!
    @IBOutlet weak var preview: UICollectionView!
    
    var loadedPreviews: [Preview] = []
    var queryDic: [String: String?] = ["s": nil, "g": nil, "y": nil, "m": nil]
    var imageScale: Network.scale = .large
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.delegate = self
        preview.dataSource = self
        setRadiusOfFrame()
        setRadiusOfSelectButtons()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSubject(_ sender: UIButton) {
        let idx = Int(sender.tag)
        showAlertController(title: Query.shared.buttonTitles[idx], index: idx, data: Query.shared.popupButtons[idx])
    }
}


extension SearchWorkbookViewController {
    func setRadiusOfFrame() {
        frame.layer.cornerRadius = 30
    }
    
    func setRadiusOfSelectButtons() {
        selectButtons.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.cornerRadius = 10
        }
    }
    
    func showAlertController(title: String, index: Int, data: [String]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (idx, title) in data.enumerated() {
            let button = UIAlertAction(title: title, style: .default) { _ in
                let queryKey = Query.shared.queryTitle[index]
                let queryValue = Query.shared.queryOfItems[index][idx]
                
                if queryValue == "전체" {
                    self.queryDic.updateValue(nil, forKey: queryKey)
                } else {
                    self.queryDic.updateValue(queryValue, forKey: queryKey)
                }
                
                DispatchQueue.global().async {
                    self.loadPreviewFromDB()
                }
                self.selectButtons[index].setTitle(title, for: .normal)
            }
            button.setValue(UIColor.label, forKey: "titleTextColor")
            alertController.addAction(button)
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.selectButtons[index]
            popoverController.sourceRect = CGRect(x: self.selectButtons[index].bounds.midX, y: self.selectButtons[index].bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addDumyPreview(json: String) {
        let dumyImage = UIImage(named: "256img_2")!
        let dumyImageData = dumyImage.pngData()!
        for i in 1...15 {
            let dumyPreview = Preview(wid: i, title: "Dumy Preview Title", image: "dumyImageData")
            loadedPreviews.append(dumyPreview)
        }
        preview.reloadData()
    }
    
    func loadPreviewFromDB() {
        let queryItem = queryStringOfPreviews()
        Network.downloadPreviews(queryItems: queryItem) { searchPreview in
            self.loadedPreviews = searchPreview.workbooks
            DispatchQueue.main.async {
                self.preview.reloadData()
            }
        }
    }
    
    func queryStringOfPreviews() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        queryDic.forEach {
            if($0.value != nil){
                queryItems.append(URLQueryItem(name: $0.key, value: $0.value!))
            }
        }
        return queryItems
    }
    
    func showAlertToAddPreview(index: Int) {
        let selectedPreview = loadedPreviews[index]
        print(selectedPreview)
        let alert = UIAlertController(title: selectedPreview.title,
            message: "해당 시험을 추가하시겠습니까?",
            preferredStyle: UIAlertController.Style.alert)
        
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let ok = UIAlertAction(title: "추가", style: .default) { _ in
            self.addPreview(selectedPreview: selectedPreview)
        }
        
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func addPreview(selectedPreview: Preview) {
        guard let DBDatas = loadSidsFromDB(wid: selectedPreview.wid) else { return }
        let loadedWorkbook = DBDatas.0
        let sids = DBDatas.1
        
        let preview_core = Preview_Core(context: CoreDataManager.shared.context)
        preview_core.setValues(preview: selectedPreview, subject: loadedWorkbook.subject, sids: sids)
        preview_core.setValue(loadImageData(imageString: selectedPreview.image), forKey: "image")
        
        do {
            try CoreDataManager.shared.appDelegate.saveContext()
            print("save complete")
            NotificationCenter.default.post(name: ShowDetailOfWorkbookViewController.refresh, object: self)
            self.dismiss(animated: true, completion: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loadSidsFromDB(wid: Int) -> (Workbook, [Int])? {
        guard let dbURL = URL(string: Network.workbookDirectory(wid: wid)) else {
            print("Error of url")
            return nil
        }
        do {
            guard let jsonData = try String(contentsOf: dbURL).data(using: .utf8) else {
                print("Error of jsonData")
                return nil
            }
            let getJsonData: SearchWorkbook = try! JSONDecoder().decode(SearchWorkbook.self, from: jsonData)
            // 지금은 sid 값들만 추출
            let workbook = getJsonData.workbook
            let sections = getJsonData.sections
            var sids: [Int] = []
            sections.forEach { sids.append($0.sid) }
            return (workbook, sids)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func loadImageData(imageString: String) -> Data? {
        let imageUrlString = Network.workbookImageDirectory(scale: imageScale) + imageString
        let url = URL(string: imageUrlString)!
        guard let data = try? Data(contentsOf: url) else { return nil }
        return data
    }
}

extension SearchWorkbookViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedPreviews.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchedPreviewCell", for: indexPath) as? SearchedPreviewCell else { return UICollectionViewCell() }
        // 문제번호 설정
        let imageUrlString = Network.workbookImageDirectory(scale: imageScale) + loadedPreviews[indexPath.row].image
        let url = URL(string: imageUrlString)!
        cell.imageView.kf.setImage(with: url)
        cell.title.text = loadedPreviews[indexPath.row].title
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showAlertToAddPreview(index: indexPath.row)
    }
    
}

extension SearchWorkbookViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (preview.frame.width)/5
        let height = preview.frame.height/3
        
        return CGSize(width: width, height: height)
    }
}

class SearchedPreviewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
}
