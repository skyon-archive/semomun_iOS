//
//  MultipleWith5AnswerWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit

final class MultipleWith5AnswerWideVC: FormTwo {
    static let identifier = "MultipleWith5AnswerWideVC"
    
    var viewModel: MultipleWith5AnswerVM?
    
    override func viewDidLoad() {
        self.delegate = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel?.endTimeRecord()
    }
}

extension MultipleWith5AnswerWideVC: CollectionCellDelegate {
    func reload() {
        self.viewModel?.delegate?.reload()
    }
    
    func showExplanation(image: UIImage?, pid: Int) {
        if let explanationId = self.explanationId {
            if explanationId == pid {
                self.closeExplanation()
            } else {
                self.explanationId = pid
                self.explanationView.configureImage(to: image) // 이미지 바꿔치기
            }
        } else {
            // 새로 생성
            self.explanationId = pid
            self.view.addSubview(self.explanationView)
            self.explanationView.frame = self.canvasView.frame
            
            self.explanationView.configureImage(to: image)
            self.explanationView.addShadow()
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.explanationView.alpha = 1
            }
        }
    }
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}

extension MultipleWith5AnswerWideVC: FormTwoDelegate {
    var cellNibName: String {
        return "Cells"
    }
    
    var cellIdentifier: String {
        return MultipleWith5Cell.identifier
    }
    
    var pagePencilData: Data? {
        return self.viewModel?.pagePencilData
    }
    
    func updatePagePencilData(_ data: Data) {
        self.viewModel?.updatePagePencilData(to: data)
    }
    
    var cellCount: Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func getCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, toolPicker)
        
        return cell
    }
    
    func previousPage() {
        self.viewModel?.delegate?.beforePage()
    }
    
    func nextPage() {
        self.viewModel?.delegate?.nextPage()
    }
}
