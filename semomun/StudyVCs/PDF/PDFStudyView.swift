//
//  PDFStudyView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/16.
//

import PDFKit
import UIKit

class PDFStudyView: UIViewController {
    let pdfView = PDFView()
    let thumbnailView = PDFThumbnailView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubviews(pdfView, thumbnailView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: thumbnailView.topAnchor).isActive = true
        
        thumbnailView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        thumbnailView.thumbnailSize = CGSize(width: 30, height: 50)
        thumbnailView.layoutMode = .horizontal
        thumbnailView.pdfView = pdfView
        
        guard let path = Bundle.main.url(forResource: "TestPDF", withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }
        
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.backgroundColor = .black
        
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        NotificationCenter.default.addObserver(forName: NSNotification.Name.PDFViewPageChanged, object: nil, queue: .main) { [weak self] _ in
            guard let scaleFactor = self?.pdfView.scaleFactor,
                  let sizeToFit = self?.pdfView.scaleFactorForSizeToFit else { return }
            self?.pdfView.minScaleFactor = sizeToFit
        }

        pdfView.autoScales = true
        
        pdfView.pageShadowsEnabled = false
        
        let dismiss = UIButton()
        let buttonImg = UIImage(systemName: "xmark")
        dismiss.setImage(buttonImg, for: .normal)
        dismiss.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dismiss)
        
        NSLayoutConstraint.activate([
            dismiss.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            dismiss.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dismiss.widthAnchor.constraint(equalToConstant: 40),
            dismiss.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pdfView.layoutDocumentView()
    }
}
