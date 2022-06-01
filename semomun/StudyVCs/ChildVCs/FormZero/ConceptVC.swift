//
//  ConceptVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class ConceptVC: FormZero {
    static let identifier = "ConceptVC" // form == 0 && type == -1
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    var viewModel: ConceptVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("개념 willAppear")
        self.configureUI()
        self.checkScoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("개념 didAppear")
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("개념 willDisappear")
        
        self.endTimeRecord()
        self.timerView.removeFromSuperview()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
}

extension ConceptVC {
    private func configureUI() {
        self.configureStar()
    }
    
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 15)
        ])
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func checkScoring() {
        guard let problem = self.viewModel?.problem else { return }
        let terminated = problem.terminated
              
        if terminated == false {
            self.viewModel?.delegate?.addScoring(pid: Int(problem.pid))
        }
    }
}

extension ConceptVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
