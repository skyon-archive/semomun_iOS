//
//  HomeVCAdapterView.swift
//  semomun
//
//  Created by 신영민 on 2022/07/22.
//

import UIKit

@objc(HomeVCAdapterView)
class HomeVCAdapterView: UIView {
    weak var viewController: UIViewController?
    
    var config: NSDictionary = [:] {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if viewController == nil {
            embed()
        } else {
            viewController?.view.frame = bounds
        }
    }
    
    private func embed() {
        guard
            let parentVC = parentViewController else {
            return
        }

        let vc = HomeVC()
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        self.viewController = vc
    }
}
