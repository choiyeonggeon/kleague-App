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
    private let lastLabel = UILabel()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let header = moreTableView.tableHeaderView {
            let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if header.frame.size.height != size.height || header.frame.size.width != view.frame.width {
                header.frame.size = CGSize(width: view.frame.width, height: size.height)
                moreTableView.tableHeaderView = header
                
            }
        }
        
        if let footer = moreTableView.tableFooterView {
            let size = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if footer.frame.height != size.height || footer.frame.width != view.frame.width {
                footer.frame.size = CGSize(width: view.frame.width, height: size.height)
                moreTableView.tableFooterView = footer
            }
        }
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
        
        // MARK: - Header View 설정
        let headerContainer = UIView()
        headerContainer.backgroundColor = .clear
        
        loginButton.setTitle("로그인", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.backgroundColor = .systemGray6
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        headerContainer.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(18)
            $0.height.equalTo(44)
        }
        
        // 높이 계산 후 frame 설정
        headerContainer.layoutIfNeeded()
        let headerHeight = headerContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight)
        
        moreTableView.tableHeaderView = headerContainer
        
        // MARK: - Footer View 설정
        let footerContainer = UIView()
        footerContainer.backgroundColor = .clear
        
        lastLabel.text = "문의 및 건의 사항이 있으시다면\ngugchugyeojido@gmail.com\n031)1234-5678\n으로 연락해 주시기 바랍니다."
        lastLabel.numberOfLines = 0
        lastLabel.font = .systemFont(ofSize: 14)
        lastLabel.textColor = .gray
        lastLabel.textAlignment = .center
        
        footerContainer.addSubview(lastLabel)
        lastLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        footerContainer.layoutIfNeeded()
        let footerHeight = footerContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        footerContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: footerHeight)
        
        moreTableView.tableFooterView = footerContainer
        
        // MARK: - TableView 설정
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
        
        switch indexPath.row {
        case 0:
            let noticeVC = NoticeVC()
            navigationController?.pushViewController(noticeVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 1:
            let PersonalVC = PersonalInformationVC()
            navigationController?.pushViewController(PersonalVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 2:
            let teamVC = TeamVC()
            navigationController?.pushViewController(teamVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 3:
            let playerAndDirectorVC = PlayerAndDirectorVC()
            navigationController?.pushViewController(playerAndDirectorVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 4:
            let eventVC = eventVC()
            navigationController?.pushViewController(eventVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 5:
            let cheeringTeamVC = CheeringTeamListVC()
            navigationController?.pushViewController(cheeringTeamVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
        }
        
        switch indexPath.row {
        case 6:
            let customerServiceVC = CustomerServiceVC()
            navigationController?.pushViewController(customerServiceVC, animated: true)
        default:
            print("선택된 항목: \(items[indexPath.row])")
            break
        }
    }
}
