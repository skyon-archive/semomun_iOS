//
//  LoginSelectVCAdapterView.swift
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

import UIKit

@objc(LoginSelectVCAdapterView)
class LoginSelectVCAdapterView: UIView {
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
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }

        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        self.viewController = vc
    }
}
