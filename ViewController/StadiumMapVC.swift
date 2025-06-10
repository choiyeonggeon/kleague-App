//
//  StadiumMapVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/3/25.
//

import UIKit
import NMapsMap
import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class StadiumMapVC: UIViewController {
    
    private var markers: [NMFMarker] = []
    private let mapView = NMFMapView()
    private let locationManager = CLLocationManager()
    private let restaurantService = RestaurantService()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        checkLocationPermission()
        searchAndDisplayResults(for: "수원월드컵경기장")
    }
    
    private func setupMapView() {
        mapView.frame = view.bounds
        view.addSubview(mapView)

        // 기본 카메라 위치: 수원월드컵경기장
        let stadiumLocation = NMGLatLng(lat: 37.28639, lng: 127.03694)
        let cameraUpdate = NMFCameraUpdate(scrollTo: stadiumLocation)
        mapView.moveCamera(cameraUpdate)
    }
    
    private func checkLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func searchAndDisplayResults(for query: String) {
        restaurantService.fetchRestaurants(keyword: query)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] restaurants in
                self?.addMarkers(restaurants)
            }, onFailure: { error in
                print("❌ 검색 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func addMarkers(_ places: [Restaurant]) {
        print("addMarkers 호출, places count: \(places.count)")
        // 기존 마커 제거
        for marker in markers {
            marker.mapView = nil
        }
        markers.removeAll()
        
        // 새 마커 추가
        for place in places {
            print("마커 추가: \(place.name), 위도: \(place.latitude), 경도: \(place.longitude)")
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.captionText = place.name
            marker.mapView = mapView
            markers.append(marker)
        }
        
        if let first = places.first {
               let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: first.latitude, lng: first.longitude))
               cameraUpdate.animation = .easeIn
               mapView.moveCamera(cameraUpdate)
               print("지도 카메라 이동: \(first.latitude), \(first.longitude)")
           }
    }
}
