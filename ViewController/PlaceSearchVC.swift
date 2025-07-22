////
////  PlaceSearchVC.swift
////  KleagueApp
////
////  Created by 최영건 on 7/15/25.
////
//
//import UIKit
//import SnapKit
//import RxSwift
//import RxCocoa
//
//class PlaceSearchVC: UIViewController {
//    
//    let searchBar = UISearchBar()
//    let categoryField = UITextField()
//    let tableView = UITableView()
//    
//    let viewModel = PlaceSearchViewModel()
//    let disposeBag = DisposeBag()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupPlaceUI()
//        bind()
//    }
//    
//    private func setupPlaceUI() {
//        view.backgroundColor = .white
//        title = "맛집 검색"
//        
//        categoryField.placeholder = "카테고리 필터 (예: 한식)"
//        categoryField.borderStyle = .roundedRect
//        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        tableView.rowHeight = UITableView.automaticDimension
//        
//        view.addSubview(searchBar)
//        view.addSubview(categoryField)
//        view.addSubview(tableView)
//        
//        searchBar.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide)
//            $0.leading.trailing.equalToSuperview()
//        }
//        
//        categoryField.snp.makeConstraints {
//            $0.top.equalTo(searchBar.snp.bottom).offset(4)
//            $0.leading.trailing.equalToSuperview().inset(22)
//            $0.height.equalTo(36)
//        }
//        
//        tableView.snp.makeConstraints {
//            $0.top.equalTo(categoryField.snp.bottom).offset(4)
//            $0.leading.trailing.bottom.equalToSuperview()
//        }
//    }
//    
//    private func bind() {
//        searchBar.rx.text.orEmpty
//            .bind(to: viewModel.keyword)
//            .disposed(by: disposeBag)
//        
//        categoryField.rx.text.orEmpty
//            .bind(to: viewModel.filteredCategory)
//            .disposed(by: disposeBag)
//        
//        viewModel.searchResults
//            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { [weak self] _, item, cell in
//                let isFav = self?.viewModel.isFavorite(item) == true
//                cell.textLabel?.numberOfLines = 0
//                cell.textLabel?.text = "\(item.cleanTitle)\n📍 \(item.address)\(isFav ? " ⭐️" : "")"
//            }
//            .disposed(by: disposeBag)
//        
//        tableView.rx.modelSelected(PlaceSearch.self)
//            .subscribe(onNext: { [weak self] item in
//                let detailVC = PlaceDetailVC(place: item, viewModel: self?.viewModel)
//                self?.navigationController?.pushViewController(detailVC, animated: true)
//            })
//            .disposed(by: disposeBag)
//    }
//}
