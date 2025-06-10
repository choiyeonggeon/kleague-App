//
//  KleagueTableViewModel.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

class KleagueTableViewModel {
    let leagueID = BehaviorRelay<Int>(value: 7034)
    let teams = BehaviorRelay<[KleagueTeam]>(value: [])
    let disposeBag = DisposeBag()
    
    init() {
        leagueID
            .flatMapLatest { APIService.shared.fetchKleagueTableData(for: $0) }
            .bind(to: teams)
            .disposed(by: disposeBag)

    }
}
