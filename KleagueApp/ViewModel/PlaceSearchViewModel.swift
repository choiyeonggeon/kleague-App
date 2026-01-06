////
////  PlaceSearchViewModel.swift
////  KleagueApp
////
////  Created by 최영건 on 7/15/25.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
//
//class PlaceSearchViewModel {
//    let keyword = BehaviorRelay<String>(value: "")
//    let filteredCategory = BehaviorRelay<String>(value: "")
//    let searchResults = BehaviorRelay<[PlaceSearch]>(value: [])
//    
//    private let disposeBag = DisposeBag()
//    private let service = NaverPlaceSearchService()
//    
//    init() {
//        Observable.combineLatest(keyword, filteredCategory)
//            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
//            .flatMapLatest { [weak self] (keyword, category) -> Observable<[PlaceSearch]> in
//                guard !keyword.isEmpty else { return .just([]) }
//                return self?.service.search(keyword: keyword)
//                    .map { items in
//                        category.isEmpty ? items :
//                        items.filter { $0.category.contains(category) }
//                    }
//                    .catchAndReturn([]) ?? .just([])
//            }
//            .bind(to: searchResults)
//            .disposed(by: disposeBag)
//    }
//    
//    func toggleFavorite(_ place: PlaceSearch) {
//        var favorites = getFavorites()
//        if favorites.contains(place.id) {
//            favorites.removeAll { $0 == place.id }
//        } else {
//            favorites.append(place.id)
//        }
//        UserDefaults.standard.setValue(favorites, forKey: "favorites")
//    }
//    
//    func isFavorite(_ place: PlaceSearch) -> Bool {
//        getFavorites().contains(place.id)
//    }
//    
//    private func getFavorites() -> [String] {
//        UserDefaults.standard.stringArray(forKey: "favorites") ?? []
//    }
//}
