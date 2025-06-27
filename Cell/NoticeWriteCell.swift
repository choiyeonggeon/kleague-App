//
//  NoticeWriteCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit

class NoticeWriteCell: UITableViewCell {
    static let identifier = "NoticeWriteCell"
    
    let writeButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        writeButton.setTitle("📢 공지사항 작성", for: .normal)
        writeButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        writeButton.setTitleColor(.systemBlue, for: .normal)

        contentView.addSubview(writeButton)
        writeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(44)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
