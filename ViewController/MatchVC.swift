//
//  MatchVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MatchVC: UIViewController {
    
    private let titleLabel = UILabel()
    let segmentedControl1 = UISegmentedControl(items: ["K리그1", "K리그2"])
    let matchTableView = UITableView()
    private let prevMonthButton = UIButton()
    private let nextMonthButton = UIButton()
    private let monthLabel = UILabel()
    
    private var allMatches: [Match] = []
    private let matchesRelay = BehaviorRelay<[Match]>(value: [])
    private let disposeBag = DisposeBag()
    
    private var selectedLeagueID = 292
    private var selectedMonth = Calendar.current.component(.month, from: Date()) {
        didSet {
            updateMonthLabel()
            filterMatchesByMonth()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMatchData()
        bindActions()
        fetchMatch()
    }
}

extension MatchVC {
    private func setMatchData() {
        title = "경기/결과"
        view.backgroundColor = .white
        view.addSubview(segmentedControl1)
        view.addSubview(matchTableView)
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        prevMonthButton.setTitle("<", for: .normal)
        nextMonthButton.setTitle(">", for: .normal)
        [prevMonthButton, nextMonthButton].forEach {
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 24)
        }
        
        monthLabel.font = .boldSystemFont(ofSize: 24)
        monthLabel.textColor = .black
        monthLabel.textAlignment = .center
        updateMonthLabel()
        
        matchTableView.register(MatchCell.self, forCellReuseIdentifier: "MatchCell")
        matchTableView.rowHeight = UITableView.automaticDimension
        matchTableView.estimatedRowHeight = 100
        matchTableView.backgroundColor = .systemGray6
        matchTableView.separatorStyle = .none
        
        [titleLabel, segmentedControl1, prevMonthButton, monthLabel, nextMonthButton, matchTableView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        segmentedControl1.selectedSegmentIndex = 0
        segmentedControl1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        prevMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(segmentedControl1.snp.bottom).offset(16)
        }
        
        monthLabel.snp.makeConstraints {
            $0.centerY.equalTo(prevMonthButton)
            $0.centerX.equalToSuperview()
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(prevMonthButton)
        }
        
        matchTableView.snp.makeConstraints {
            $0.top.equalTo(prevMonthButton.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MatchVC {
    private func bindActions() {
        segmentedControl1.rx.selectedSegmentIndex.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            self.selectedLeagueID = (index == 0) ? 292 : 293
            self.fetchMatch()
        })
        .disposed(by: disposeBag)
        
        prevMonthButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.selectedMonth = max(1, self.selectedMonth - 1)
        })
        .disposed(by: disposeBag)
        
        nextMonthButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.selectedMonth = min(12, self.selectedMonth + 1)
        })
        .disposed(by: disposeBag)
        
        matchesRelay.bind(to: matchTableView.rx.items(cellIdentifier: "MatchCell", cellType: MatchCell.self)) { row, match, cell in cell.configure(with: match)
        }
        .disposed(by: disposeBag)
    }
    
    private func filterMatchesByMonth() {
        let calendar = Calendar.current
        let filter = allMatches.filter {
            if let date = ISO8601DateFormatter().date(from: $0.fixture.date) {
                return calendar.component(.month, from: date) == selectedMonth
            }
            return false
        }
        matchesRelay.accept(filter)
    }
    
    private func fetchMatch() {
        APIService.shared.fetchKleagueMatches(leagueID: selectedLeagueID)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] matches in
                self?.allMatches = matches
                self?.filterMatchesByMonth()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateMonthLabel() {
        monthLabel.text = "\(selectedMonth)월"
    }
}
