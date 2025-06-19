//
//  PDFViewerVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/19/25.
//

import UIKit
import PDFKit

class PDFViewerVC: UIViewController {
    
    private var pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "개인정보처리방침"
        setupPDFView()
        loadPDF()
    }
    
    private func setupPDFView() {
        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        pdfView.autoScales = true
    }
    
    private func loadPDF() {
        if let url = Bundle.main.url(forResource: "privacyPolicy", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: url)
        }
    }
}
