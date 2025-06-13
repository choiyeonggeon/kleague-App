//
//  RestaurantVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NMapsMap

class RestaurantVC: UIViewController {

    private let mapView = NMFMapView()
    private let searchBar = UISearchBar()
    private let restaurantService = RestaurantService()
    private var markers: [NMFMarker] = []
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "맛집 검색"
        setupMapView()
        setupSearchBar()
    }

    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 초기 위치 수원월드컵경기장
        let stadiumLocation = NMGLatLng(lat: 37.28639, lng: 127.03694)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: stadiumLocation))
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.placeholder = "맛집 검색"
        searchBar.backgroundImage = UIImage()
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-28)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        if #available(iOS 13.0, *) {
            let textField = searchBar.searchTextField
            textField.backgroundColor = .systemGray6
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
    }

    private func addMarkers(_ restaurants: [Restaurant]) {
        // 기존 마커 제거
        markers.forEach { $0.mapView = nil }
        markers.removeAll()

        // 새 마커 추가
        restaurants.forEach { place in
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.captionText = place.name
            marker.mapView = mapView
            markers.append(marker)
        }

        if let first = restaurants.first {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: first.latitude, lng: first.longitude))
            cameraUpdate.animation = .easeIn
            mapView.moveCamera(cameraUpdate)
        }
    }
}

extension RestaurantVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !keyword.isEmpty else { return }

        restaurantService.fetchRestaurants(keyword: keyword)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] restaurants in
                self?.addMarkers(restaurants)
            }, onFailure: { error in
                print("검색 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)

        searchBar.resignFirstResponder()
    }
}
