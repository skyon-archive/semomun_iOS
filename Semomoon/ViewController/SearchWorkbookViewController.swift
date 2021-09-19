//
//  selectWorkbookViewController.swift
//  selectWorkbookViewController
//
//  Created by qwer on 2021/09/12.
//

import UIKit

class SearchWorkbookViewController: UIViewController {

    @IBOutlet weak var frame: UIView!
    @IBOutlet var selectButtons: [UIButton]!
    @IBOutlet weak var preview: UICollectionView!
    
    var buttonTitles: [String] = []
    var popupButtons: [[String]] = []
    var loadedPreviews: [Preview] = []
    
    let dbUrlString = "https://9932-61-79-139-252.ngrok.io/workbooks/preview"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.delegate = self
        preview.dataSource = self
        setPopupButtons()
        setRadiusOfFrame()
        setRadiusOfSelectButtons()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSubject(_ sender: UIButton) {
        let idx = Int(sender.tag)
        showAlertController(title: buttonTitles[idx], index: idx, data: popupButtons[idx])
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
    
    func setPopupButtons() {
        buttonTitles.append("과목 선택")
        popupButtons.append(["국어", "수학", "영어", "과학"])
        buttonTitles.append("학년 선택")
        popupButtons.append(["1학년", "2학년", "3학년"])
        buttonTitles.append("년도 선택")
        popupButtons.append(["2021년", "2020년", "2019년", "2018년"])
        buttonTitles.append("월 선택")
        popupButtons.append(["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "수능", "12월"])
    }
    
    func showAlertController(title: String, index: Int, data: [String]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        var query: String = "query something"
        
        data.forEach { title in
            let button = UIAlertAction(title: title, style: .default) { _ in
                self.selectButtons[index].setTitle(title, for: .normal)
//                self.loadPreviewFromDB(query: query)
                self.addDumyPreview(json: query)
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
            let dumyPreview = Preview(wid: i, title: "Dumy Preview Title", image: dumyImageData)
            loadedPreviews.append(dumyPreview)
        }
        preview.reloadData()
    }
    
    func loadPreviewFromDB(query: String) {
        // something query to DB
        // download json String
        guard let dbURL = URL(string: dbUrlString) else {
            print("Error of url")
            return
        }
        do {
            guard let jsonData = try String(contentsOf: dbURL).data(using: .utf8) else {
                print("Error of jsonData")
                return
            }
            let getJsonData: SearchPreview = try! JSONDecoder().decode(SearchPreview.self, from: jsonData)
            print(getJsonData.workbooks[0].wid)
            print(getJsonData.workbooks[0].title)
            print(getJsonData.workbooks[0].image)
            print(getJsonData.workbooks[1].wid)
            print(getJsonData.workbooks[1].title)
            print(getJsonData.workbooks[1].image)
        } catch let error {
            print(error.localizedDescription)
        }
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
        let imageData = loadedPreviews[indexPath.row].image
        cell.imageView.image = UIImage(data: imageData)
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
