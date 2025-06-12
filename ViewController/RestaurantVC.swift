//
//  RestaurantVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NMapsMap
import Foundation
import CoreLocation

class RestaurantVC: UIViewController {
    
    private var markers: [NMFMarker] = []
    private let mapView = NMFMapView()
    private let searchBar = UISearchBar()
    private let searchService = NaverPlaceSearchService()
    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "맛집"
        setupMap()
        setupSearchBar()
        checkLocationPermission()
    }
    
    private func setupMap() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 초기 위치: 수원월드컵경기장
        let stadiumLocation = NMGLatLng(lat: 37.2860, lng: 127.0015)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: stadiumLocation))
    }
    
    private func checkLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.placeholder = "어디로 달려가볼까요?"
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            let textField = searchBar.searchTextField
            textField.backgroundColor = UIColor.systemGray6
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(65)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    private func addMarkers(lat: Double, lng: Double, title: String) {
        let coord = convertTM128ToWGS84(x: lng, y: lat) // TM128 → 위경도 변환
        let latLng = NMGLatLng(lat: coord.latitude, lng: coord.longitude)

        let marker = NMFMarker()
        marker.position = latLng
        marker.captionText = title.htmlStripped
        marker.mapView = mapView
        markers.append(marker)

        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        cameraUpdate.animation = NMFCameraUpdateAnimation.easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    private func convertTM128ToWGS84(x: Double, y: Double) -> CLLocationCoordinate2D {
        let lon = x - 0.0000416 * y - 0.0009683
        let lat = y + 0.0000405 * x + 0.0006539
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }


}

// MARK: - HTML 태그 제거용 확장
extension String {
    var htmlStripped: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        } else {
            return self
        }
    }
}

// MARK: - 검색 기능
extension RestaurantVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
        searchService.search(keyword: keyword)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let self = self else { return }

                // 기존 마커 제거
                for marker in self.markers {
                    marker.mapView = nil
                }
                self.markers.removeAll()

                for place in places {
                    let lng = place.mapx
                    let lat = place.mapy
                    let cleanTitle = place.title

                    self.addMarkers(lat: lat, lng: lng, title: cleanTitle)
                }

            }, onError: { error in
                print("검색 실패: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
}
