//
//  selectWorkbookViewController.swift
//  selectWorkbookViewController
//
//  Created by qwer on 2021/09/12.
//

import UIKit

class SelectWorkbookViewController: UIViewController {

    @IBOutlet weak var frame: UIView!
    @IBOutlet var selectButtons: [UIButton]!
    @IBOutlet weak var preview: UICollectionView!
    
    let dataOfSubject: [String] = ["국어", "수학", "영어", "과학"]
    let dataOfGrade: [String] = ["1학년", "2학년", "3학년"]
    let dataOfYear: [String] = ["2021년", "2020년", "2019년", "2018년"]
    let dataOfMonth: [String] = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "수능", "12월"]
    var loadedPreviews: [Preview_Real] = []
    let dumyImage = UIImage(named: "256img_2")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.delegate = self
        preview.dataSource = self
        setRadiusOfFrame()
        setRadiusOfSelectButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 664 -> 132
        // 634 -> 211
        print(preview.frame.width, preview.frame.height)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSubject(_ sender: UIButton) {
        let idx = Int(sender.tag)
        switch idx {
        case 0:
            showAlertController(title: "과목 선택", index: idx, data: dataOfSubject)
        case 1:
            showAlertController(title: "학년 선택", index: idx, data: dataOfGrade)
        case 2:
            showAlertController(title: "년도 선택", index: idx, data: dataOfYear)
        case 3:
            showAlertController(title: "월 선택", index: idx, data: dataOfMonth)
        default:
            break
        }
    }
}


extension SelectWorkbookViewController {
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
        
//        let titleFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)]
//        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
//        alertController.setValue(titleAttrString, forKey: "attributedContentText")
//        alertController.setValue(titleAttrString, forKey: "attributedMessage")
        
        data.forEach { title in
            let button = UIAlertAction(title: title, style: .default) { _ in
                self.selectButtons[index].setTitle(title, for: .normal)
                for _ in 0..<15 { self.addDumyPreview() }
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
    
    func addDumyPreview() {
        let dumyPreview = Preview_Real(wid: 0, title: "고3 2021년 7월 화법과 작문", image: 0)
        dumyPreview.setDumyData(data: dumyImage.jpegData(compressionQuality: 1)!)
        loadedPreviews.append(dumyPreview)
        preview.reloadData()
    }
}

extension SelectWorkbookViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedPreviews.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchedPreviewCell", for: indexPath) as? SearchedPreviewCell else { return UICollectionViewCell() }
        // 문제번호 설정
        guard let imageData = loadedPreviews[indexPath.row].imageData else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(data: imageData)
        cell.title.text = loadedPreviews[indexPath.row].preview.title
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wid = loadedPreviews[indexPath.row].preview.wid
        print(wid)
    }
    
}

extension SelectWorkbookViewController: UICollectionViewDelegateFlowLayout {
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
