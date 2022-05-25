//
//  MultipleWithConceptVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit

final class MultipleWithConceptWideVC: FormTwo {
    static let identifier = "MultipleWithConceptWideVC"
    
    var viewModel: MultipleWithConceptWideVM?
    
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
        
        let topViewHeight = self.cellLayoutable?.topViewHeight(with: problem) ?? 0
        
        return .init(baseSize.width, topViewHeight+baseSize.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWithConceptCell.identifier, for: indexPath) as? MultipleWithConceptCell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, toolPicker)
        cell.showTopShadow = indexPath.item == 0 ? false : true
        
        return cell
    }
    
    override var cellLayoutable: CellLayoutable.Type? {
        return MultipleWithConceptCell.self
    }
    
    override var pagePencilData: Data? {
        return self.viewModel?.pagePencilData
    }
    
    override var pagePencilDataWidth: CGFloat {
        if let width = self.viewModel?.pagePencilDataWidth {
            return CGFloat(width)
        } else {
            return super.pagePencilDataWidth
        }
    }
    
    override func updatePagePencilData(data: Data, width: CGFloat) {
        self.viewModel?.updatePagePencilData(to: data, width: Double(width))
    }
    
    override func previousPage() {
        self.viewModel?.delegate?.beforePage()
    }
    
    override func nextPage() {
        self.viewModel?.delegate?.nextPage()
    }
}

extension MultipleWithConceptWideVC: CollectionCellDelegate {
    func reload() {
        self.viewModel?.delegate?.reload()
    }
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}
