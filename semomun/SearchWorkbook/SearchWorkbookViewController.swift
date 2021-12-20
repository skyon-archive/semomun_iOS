//
//  SearchWorkbookViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/12.
//

import UIKit
import Kingfisher

class SearchWorkbookViewController: UIViewController {
    static let identifier = "SearchWorkbookViewController"
    
    @IBOutlet weak var frame: UIView!
    @IBOutlet var selectButtons: [UIButton]!
    @IBOutlet weak var preview: UICollectionView!
    
    var manager: SearchWorkbookManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegate()
        configureUI()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSubject(_ sender: UIButton) {
        let idx = Int(sender.tag)
        showAlertController(title: Query.shared.buttonTitles[idx], index: idx, data: Query.shared.popupButtons[idx])
    }
}

// MARK: - Configure
extension SearchWorkbookViewController {
    func configureDelegate() {
        preview.delegate = self
        preview.dataSource = self
    }
    
    func configureUI() {
        self.setRadiusOfFrame()
        self.setRadiusOfSelectButtons()
    }
    
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
}

extension SearchWorkbookViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchedPreviewCell.identifier, for: indexPath) as? SearchedPreviewCell else { return UICollectionViewCell() }
        // 문제번호 설정
        let imageUrlString = manager.imageURL(at: indexPath.item)
        cell.showImage(url: imageUrlString)
        cell.title.text = manager.title(at: indexPath.item)
        
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


extension SearchWorkbookViewController {
    func showAlertController(title: String, index: Int, data: [String]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (idx, title) in data.enumerated() {
            let button = UIAlertAction(title: title, style: .default) { _ in
                let queryKey = Query.shared.queryTitle[index]
                let queryValue = Query.shared.queryOfItems[index][idx]
                
                if queryValue == "전체" {
                    self.manager.queryDic.updateValue(nil, forKey: queryKey)
                    
                } else {
                    self.manager.queryDic.updateValue(queryValue, forKey: queryKey)
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
    
    func loadPreviewFromDB() {
        manager.loadPreviews {
            DispatchQueue.main.async {
                self.preview.reloadData()
            }
        }
    }
    
    func showAlertToAddPreview(index: Int) {
        let alert = UIAlertController(title: manager.title(at: index),
            message: "해당 시험을 추가하시겠습니까?",
            preferredStyle: UIAlertController.Style.alert)
        
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let ok = UIAlertAction(title: "추가", style: .default) { _ in
            self.loadSidsFromDB(index: index)
        }
        
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func savePreview(index: Int, workbook: WorkbookOfDB, sids: [Int]) {
        let preview_core = Preview_Core(context: CoreDataManager.shared.context)
        let preview = self.manager.preview(at: index)
        let baseURL = NetworkUsecase.URL.bookcovoerImageDirectory(manager.imageScale)
        
        preview_core.setValues(preview: preview, workbook: workbook, sids: sids, baseURL: baseURL)
        CoreDataManager.shared.appDelegate.saveContext()
    }
    
    func saveSectionHeader(sections: [SectionOfDB]) {
        let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
        
        sections.forEach {
            sectionHeader_core.setValues(section: $0, baseURL: NetworkUsecase.URL.sectionImageDirectory(manager.imageScale))
            CoreDataManager.shared.appDelegate.saveContext()
        }
        print("save complete")
        NotificationCenter.default.post(name: ShowDetailOfWorkbookViewController.refresh, object: self)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadSidsFromDB(index: Int) {
        NetworkUsecase.downloadWorkbook(wid: manager.preview(at: index).wid) { searchWorkbook in
            let workbook = searchWorkbook.workbook
            let sections = searchWorkbook.sections
            
            var sids: [Int] = []
            sections.forEach { sids.append($0.sid) }
            DispatchQueue.global().async {
                self.savePreview(index: index, workbook: workbook, sids: sids)
                self.saveSectionHeader(sections: sections)
            }
        }
    }
}

