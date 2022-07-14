//
//  LoginStartVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/05.
//

import UIKit

final class LoginStartVC: UIViewController, StoryboardController, UINavigationControllerDelegate {
    static let identifier = "LoginStartVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Login"]
    var isAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        guard let nextVC = UIStoryboard(controllerType: LoginSelectVC.self).instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
        
        self.isAnimation = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func signin(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: LoginSignupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSignupVC.identifier) as? LoginSignupVC else { return }
        
        self.isAnimation = false
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

/// https://stackoverflow.com/questions/26569488/navigation-controller-custom-transition-animation

extension LoginStartVC: UINavigationBarDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        class FadeAnimation: NSObject, UIViewControllerAnimatedTransitioning {
            func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
                return 0.3
            }
            
            func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
                let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
                if let vc = toViewController {
                    transitionContext.finalFrame(for: vc)
                    transitionContext.containerView.addSubview(vc.view)
                    vc.view.alpha = 0.0
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                                   animations: {
                        vc.view.alpha = 1.0
                    },
                                   completion: { finished in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    })
                } else {
                    NSLog("Oops! Something went wrong! 'ToView' controller is nill")
                }
            }
        }
        return self.isAnimation == true ? FadeAnimation() : nil
    }
}
