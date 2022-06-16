//
//  MultipleWithNoAnswerWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/24.
//

import Foundation
import PencilKit

final class MultipleWithNoAnswerWideVC: FormTwo {
    static let identifier = "MultipleWithNoAnswerWideVC"
    
    var viewModel: MultipleWithNoAnswerVM?
    
    private let cellType = MultipleWithNoAnswerCell.self
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureCollectionView()
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let baseSize = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        
        guard let problem = self.viewModel?.problems[indexPath.item] else {
            return baseSize
        }
        
        let topViewHeight = self.cellType.topViewHeight(with: problem)
        
        return .init(baseSize.width, topViewHeight+baseSize.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWithNoAnswerCell.identifier, for: indexPath) as? MultipleWithNoAnswerCell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.prepareForReuse(contentImage, problem, toolPicker)
        cell.showTopShadow = indexPath.item == 0 ? false : true
        
        return cell
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
        NotificationCenter.default.post(name: .previousPage, object: nil)
    }
    
    override func nextPage() {
        NotificationCenter.default.post(name: .nextPage, object: nil)
    }
    
    private func configureCollectionView() {
        let cellIdentifier = self.cellType.identifier
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
    }
}

extension MultipleWithNoAnswerWideVC: FormCellControllable {
    func refreshPageButtons() {
        self.viewModel?.delegate?.refreshPageButtons()
    }
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}

extension MultipleWithNoAnswerWideVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
