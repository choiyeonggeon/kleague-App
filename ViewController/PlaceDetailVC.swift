////
////  PlaceDetailVC.swift
////  KleagueApp
////
////  Created by 최영건 on 7/15/25.
////
//
//import UIKit
//import SnapKit
//
//class PlaceDetailVC: UIViewController {
//    private let place: PlaceSearch
//    private let viewModel: PlaceSearchViewModel?
//    
//    private let nameLabel = UILabel()
//    private let addresslabel = UILabel()
//    private let phoneLabel = UILabel()
//    private let favButton = UIButton(type: .system)
//    
//    init(place: PlaceSearch, viewModel: PlaceSearchViewModel?) {
//        self.place = place
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupPlaceDetailUI()
//        updateFavButton()
//    }
//    
//    private func setupPlaceDetailUI() {
//        nameLabel.text = place.cleanTitle
//        nameLabel.font = .boldSystemFont(ofSize: 20)
//        
//        addresslabel.text = "주소: \(place.address)"
//        phoneLabel.text = "전화: \(place.telephone ?? "없음")"
//        
//        favButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
//        
//        let stack = UIStackView(arrangedSubviews: [nameLabel, addresslabel, phoneLabel, favButton])
//        stack.axis = .vertical
//        stack.spacing = 12
//        stack.alignment = .leading
//        
//        view.addSubview(stack)
//        stack.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
//    }
//    
//    private func updateFavButton() {
//        let isFav = viewModel?.isFavorite(place) ?? false
//        favButton.setTitle(isFav ? "⭐️ 즐겨찾기 해제" : "즐겨찾기 추가", for: .normal)
//    }
//    
//    @objc private func toggleFavorite() {
//        viewModel?.toggleFavorite(place)
//        updateFavButton()
//    }
//}
