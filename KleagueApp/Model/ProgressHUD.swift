//
//  ProgressHUD.swift
//  KleagueApp
//
//  Created by 최영건 on 8/19/25.
//

import UIKit

final class ProgressHUD {
    
    private var container: UIView?
    static func show(in parent: UIView, text: String) -> ProgressHUD {
        let instance = ProgressHUD()
        let container = UIView(frame: parent.bounds)
        container.backgroundColor = UIColor(white: 0, alpha: 0.4)
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.sizeToFit()
        label.center = container.center
        container.addSubview(label)
        parent.addSubview(container)
        instance.container = container
        return instance
    }
    func dismiss() { container?.removeFromSuperview() }
}
