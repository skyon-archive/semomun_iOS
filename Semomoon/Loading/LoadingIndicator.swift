//
//  LoadingIndicator.swift
//  Semomoon
//
//  Created by qwer on 2021/11/06.
//

import UIKit

protocol loadingDelegate: AnyObject {
    func updateProgress()
}

class LoadingIndicator: UIViewController {

    @IBOutlet var loadingProgress: CircularProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    var totalPageCount: Int = 0
    var currentCount: Int = 0
    var currentPersent: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setProgress()
    }
    
    func setProgress() {
        self.loadingProgress.progressWidth = 15.0
        self.loadingProgress.trackColor = UIColor.lightGray
        self.loadingProgress.progressColor = UIColor.darkGray
        self.statusLabel.text = "\(self.currentCount)/\(self.totalPageCount)"
        self.loadingProgress.setProgressWithAnimation(duration: 0.2, value: 0.0, from: 0)
    }
}

extension LoadingIndicator: loadingDelegate {
    func updateProgress() {
        self.currentCount += 1
        let newPersent = Float(currentCount)/Float(totalPageCount)
        self.statusLabel.text = "\(self.currentCount)/\(self.totalPageCount)"
        self.loadingProgress.setProgressWithAnimation(duration: 0.2, value: newPersent, from: currentPersent)
        self.currentPersent = newPersent
    }
}
