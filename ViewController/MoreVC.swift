//
//  MoreVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import Foundation

class MoreVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let moreTableView = UITableView()
    
    let items = ["공지사항", "개인정보", "구단", "선수/감독", "이벤트", "응원가", "고객센터"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setMoreVC()
        setupMoreTableView()
        title = "더보기"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLoginButtonTitle()
    }
    
    private func setMoreVC() {
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupMoreTableView() {
        view.addSubview(moreTableView)
    
        moreTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
       
        loginButton.setTitle("로그인", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.backgroundColor = .systemGray6
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        headerView.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
        }
        moreTableView.tableHeaderView = headerView
        
        moreTableView.dataSource = self
        moreTableView.delegate = self
        moreTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
        moreTableView.separatorStyle = .singleLine
    }
    
    @objc private func loginButtonTapped() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                updateLoginButtonTitle()
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        } else {
            let loginVC = LoginVC()
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    private func updateLoginButtonTitle() {
        if Auth.auth().currentUser != nil {
            loginButton.setTitle("로그아웃", for: .normal)
        } else {
            loginButton.setTitle("로그인", for: .normal)
            
        }
    }

}

extension MoreVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택된 항목: \(items[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
