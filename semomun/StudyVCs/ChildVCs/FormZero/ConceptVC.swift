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
    
    var viewModel: ConceptVM?
    
    private lazy var timerView = ProblemTimerView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("개념 willAppear")
        self.checkScoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("개념 didAppear")
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("개념 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
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
        self.configureTimerView()
    }
    
    private func configureTimerView() {
        guard let problem = self.viewModel?.problem else { return }
        
        if problem.terminated {
            self.view.addSubview(self.timerView)
            self.timerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
                self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 15)
            ])
            
            self.timerView.configureTime(to: problem.time)
        }
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
