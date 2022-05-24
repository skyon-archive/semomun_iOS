//
//  MultipleWithSubProblemsVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

final class MultipleWithSubProblemsWideVC: FormTwo {
    static let identifier = "MultipleWithSubProblemsWideVC"
    
    var viewModel: MultipleWithSubProblemsVM?
    
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let baseSize = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        
        guard let problem = self.viewModel?.problems[indexPath.item] else {
            return baseSize
        }
        
        let topViewHeight = self.xibAwakable.topViewHeight(with: problem)
        
        return .init(baseSize.width, topViewHeight+baseSize.height)
    }
}

extension MultipleWithSubProblemsWideVC: CollectionCellDelegate {
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

extension MultipleWithSubProblemsWideVC: FormTwoDelegate {
    var xibAwakable: CellLayoutable.Type {
        return SubProblemCell.self
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubProblemCell.identifier, for: indexPath) as? SubProblemCell else { return UICollectionViewCell() }
        
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

