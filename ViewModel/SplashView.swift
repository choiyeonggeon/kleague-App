//
//  SplashView.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit

class SplashView: UIViewController {
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SplashViewImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        
    }
}

extension SplashView {
    private func setUI() {
        view.addSubview(logoImage)
    }
    
    private func setLayout() {
        logoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
            
        }
    }
}
