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
    
    let dbUrlString = "https://ccee-118-36-227-50.ngrok.io/workbooks/preview/"
    let imageUrlString = "https://ccee-118-36-227-50.ngrok.io/images/workbook/64x64/"
    
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
        var components = URLComponents(string: dbUrlString)
        var queryItems: [URLQueryItem] = []
        queryDic.forEach {
            if($0.value != nil){
                queryItems.append(URLQueryItem(name: $0.key, value: $0.value!))
            }
        }
        components?.queryItems = queryItems
        guard let dbURL = components?.url else {
            print("Error of url")
            return
        }

        // 세션 생성, 환경설정
        let defaultSession = URLSession(configuration: .default)
        
        // Request
        let request = URLRequest(url: dbURL)
        
        // dataTask
        let dataTask = defaultSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // getting Data Error
            guard error == nil else {
                print("Error occur: \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            if let getJsonData: SearchPreview = try? JSONDecoder().decode(SearchPreview.self, from: data) {
                // 원하는 작업
                self.loadedPreviews = getJsonData.workbooks
                DispatchQueue.main.async {
                    self.preview.reloadData()
                }
            }
        }
        dataTask.resume()
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
        let imageUrlString = imageUrlString + loadedPreviews[indexPath.row].image
        let url = URL(string: imageUrlString)!
        cell.imageView.kf.setImage(with: url)
        cell.title.text = loadedPreviews[indexPath.row].title
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPreview = loadedPreviews[indexPath.row]
        // 데이터 넘기기
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "ShowDetailOfWorkbookViewController") as? ShowDetailOfWorkbookViewController else { return }
        nextVC.selectedPreview = selectedPreview
        self.present(nextVC, animated: true, completion: nil)
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
