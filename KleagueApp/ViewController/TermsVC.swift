//
//  TermsVC.swift
//  KleagueApp
//
//  Created by 최영건 on 7/1/25.
//

import UIKit
import SnapKit

class TermsVC: UIViewController {
    private let termsTextView = UITextView()
    private let agreeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTermsUI()
    }
    
    private func setupTermsUI() {
        termsTextView.text = """
            [이용약관]
            1. 본 앱은 사용자 생성 콘텐츠(게시글, 댓글 등)를 포함합니다.
            2. 폭력적이거나 불쾌한 콘텐츠에 대해 무관용 원칙을 적용합니다.
            3. 사용자는 해당 콘텐츠를 신고할 수 있으며, 운영진은 24시간 내에 조치합니다.
            4. 본 약관에 동의하지 않을 경우, 서비스를 이용하실 수 없습니다.
            """
        
        termsTextView.isEditable = false
        termsTextView.font = .systemFont(ofSize: 15)
        
        agreeButton.setTitle("위 약관에 동의합니다.", for: .normal)
        agreeButton.addTarget(self, action: #selector(didTapAgree), for: .touchUpInside)
        
        view.addSubview(termsTextView)
        view.addSubview(agreeButton)
        
        termsTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(agreeButton.snp.top).offset(-20)
        }
        
        agreeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    @objc private func didTapAgree() {
        UserDefaults.standard.set(true, forKey: "didAgreeToTerms")

        let mainVC = KleagueVC()
        let nav = UINavigationController(rootViewController: mainVC)

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
