//
//  KleagueTableViewModel.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import Foundation
import RxSwift
import RxRelay

class KleagueTableViewModel {
    let leagueID = BehaviorRelay<Int>(value: 292)
    let standings = PublishRelay<[TeamStanding]>()

    private let disposeBag = DisposeBag()

    init() {
        leagueID
            .flatMapLatest { id in
                APIService.shared.fetchKleagueStandings(for: id)
            }
            .bind(to: standings)
            .disposed(by: disposeBag)
    }
}
