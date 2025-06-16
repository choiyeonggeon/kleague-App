//
//  KleagueVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit

class KleagueVC: UIViewController {
    
    private let tabBarView = UIView()
    private let containerView = UIView()
    private var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        switchTab(index: 0)
        
    }
    
    private let tabs: [(title: String, icon: String, vc: UIViewController)] = [
        ("커뮤니티", "soccerball", CommunityVC()),
        ("맛집", "fork.knife.circle.fill", RestaurantVC()),
        ("홈", "house.fill", HomeVC()),
        ("순위", "list.number", KleagueTableVC()),
        ("더보기", "ellipsis.circle", MoreVC())
    ]
    
    private func setupLayout() {
        view.addSubview(tabBarView)
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints {
                  $0.top.leading.trailing.equalToSuperview()
                  $0.bottom.equalTo(tabBarView.snp.top)
              }

              tabBarView.snp.makeConstraints {
                  $0.leading.trailing.bottom.equalToSuperview()
                  $0.height.equalTo(100)
              }

              tabBarView.backgroundColor = .systemBackground
              setupTabButtons()
    }
    
    private func setupTabButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        tabBarView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        for (index, tab) in tabs.enumerated() {
            let button = UIButton(type: .system)
           
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.title = tab.title
                config.image = UIImage(systemName: tab.icon)
                config.imagePlacement = .top
                config.imagePadding = 6
                config.baseForegroundColor = .label
                config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
                button.configuration = config
            } else {
                button.setTitle(tab.title, for: .normal)
                button.setImage(UIImage(systemName: tab.icon), for: .normal)
                button.tintColor = .label
                button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
                
                button.contentVerticalAlignment = .center
                button.contentHorizontalAlignment = .center
                button.imageView?.contentMode = .scaleAspectFit
                button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 0)
            }
            
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        switchTab(index: sender.tag)
    }
    
    private func switchTab(index: Int) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        
        let selectedVC = tabs[index].vc
        addChild(selectedVC)
        containerView.addSubview(selectedVC.view)
        selectedVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectedVC.didMove(toParent: self)
        
        currentVC = selectedVC
        
        view.bringSubviewToFront(tabBarView)
        
    }
    
}

