//
//  SearchVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class SearchVC: UIViewController {
    
    static let identifier = "SearchVC"
    static let storyboardName = "HomeSearchBookshelf"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func addBook(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SearchWorkbookViewController.identifier) as? SearchWorkbookViewController else { return }
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        nextVC.manager = SearchWorkbookManager(filter: [], category: "수능모의고사", networkUseCase: networkUseCase)
        self.present(nextVC, animated: true, completion: nil)
    }
}
