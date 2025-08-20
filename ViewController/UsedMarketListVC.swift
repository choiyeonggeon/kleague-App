//
//  UsedMarketListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/5/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class UsedMarketListVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let writeButton = UIButton()
    
    private var products: [UsedProduct] = []
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UsedProductCell.self, forCellReuseIdentifier: UsedProductCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        startListening()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "중고 거래"
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(writeButton)
        
        searchBar.placeholder = "원하는 물건을 검색해보세요!"
        searchBar.delegate = self
                
        writeButton.setTitle("+", for: .normal)
        writeButton.setTitleColor(.white, for: .normal)
        writeButton.backgroundColor = .systemBlue
        writeButton.layer.cornerRadius = 25
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
        writeButton.titleLabel?.font = .systemFont(ofSize: 30)
        
        [titleLabel, searchBar, tableView, writeButton].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        writeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
    
    @objc private func didTapWriteButton() {
        guard Auth.auth().currentUser != nil else {
            let alert = UIAlertController(title: "로그인 필요", message: "거래 글쓰기는 로그인 후 이용 가능합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let vc = UsedMarketWriteVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startListening() {
        listener = db.collection("used_market")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Used market listener error: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.products = docs.map { UsedProduct(id: $0.documentID, data: $0.data()) }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

extension UsedMarketListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { products.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsedProductCell.identifier, for: indexPath) as? UsedProductCell else {
            return UITableViewCell()
        }
        
        let p = products[indexPath.row]
        cell.configure(with: p)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath) {
        tableView.deselectRow(at: indexpath, animated: true)
        let p = products[indexpath.row]
        let detail = UsedMarketDetailVC()
        detail.product = p
        navigationController?.pushViewController(detail, animated: true)
        
    }
}

extension UsedMarketListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.reloadData()
            return
        }
        
        let filtered = products.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) }
        self.products = filtered
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        startListening()
    }
    
}
