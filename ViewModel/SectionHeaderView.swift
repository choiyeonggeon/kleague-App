//
//  SectionHeaderView.swift
//  KleagueApp
//
//  Created by 최영건 on 6/25/25.
//

import UIKit
import SnapKit

class SectionHeaderView: UICollectionReusableView {
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
