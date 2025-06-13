//
//  StadiumMapVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/3/25.
//

import UIKit
import SnapKit
import NMapsMap
import CoreLocation
import RxSwift

class StadiumMapVC: UIViewController {

    private var markers: [NMFMarker] = []
    private let mapView = NMFMapView()
    private let locationManager = CLLocationManager()
    private let restaurantService = RestaurantService()
    private let locationButton = NMFLocationButton()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationButton()
        checkLocationPermission()
        searchAndDisplayResults(for: "수원월드컵경기장")
    }

    private func setupMapView() {
        view.addSubview(mapView)
        mapView.frame = view.bounds

        // 기본 카메라 위치: 수원월드컵경기장 (WGS84 위경도)
        let stadiumLocation = NMGLatLng(lat: 37.28639, lng: 127.03694)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: stadiumLocation))
    }

    private func setupLocationButton() {
        view.addSubview(locationButton)
        locationButton.mapView = mapView
        locationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(32)
            $0.width.height.equalTo(44)
        }
    }

    private func checkLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    private func searchAndDisplayResults(for query: String) {
        restaurantService.fetchRestaurants(keyword: query)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] restaurants in
                self?.addMarkers(restaurants)
            }, onFailure: { error in
                print("검색 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func addMarkers(_ restaurants: [Restaurant]) {
        // 기존 마커 제거
        markers.forEach { $0.mapView = nil }
        markers.removeAll()

        // 새로운 마커 추가
        restaurants.forEach { place in
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.captionText = place.name
            marker.mapView = mapView
            markers.append(marker)
        }

        // 첫번째 맛집 위치로 지도 이동 (애니메이션 포함)
        if let first = restaurants.first {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: first.latitude, lng: first.longitude))
            cameraUpdate.animation = .easeIn
            mapView.moveCamera(cameraUpdate)
        }
    }
}

extension StadiumMapVC: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.positionMode = .direction
        default:
            mapView.positionMode = .normal
        }
    }
}
