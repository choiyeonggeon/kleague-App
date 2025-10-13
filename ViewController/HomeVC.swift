//
//  HomeVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import SafariServices
import FirebaseFirestore

struct News {
    let title: String
    let source: String
    let url: String
}

struct BigMatch {
    let id: String
    let league: String
    let match: String
    let stadium: String
    let datetime: Date
    let url: String
}

class HomeVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let instagramButton = UIButton()
    private var collectionView: UICollectionView!
    
    private var bigMatches: [BigMatch] = []
    private var newsList: [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupUI()
        title = "홈"
        
        fetchBigMatches()
        fetchLatestNews()
    }
    
    private func setupUI() {
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        instagramButton.setImage(UIImage(named: "insta"), for: .normal)
        instagramButton.imageView?.contentMode = .scaleAspectFit
        instagramButton.addTarget(self, action: #selector(openInstagram), for: .touchUpInside)
        view.addSubview(instagramButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        instagramButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            group.interItemSpacing = .fixed(16) // ✅ 안전하게 간격 설정
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) // 여기는 사용 가능
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(40)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(HomeBigMatchCell.self, forCellWithReuseIdentifier: "BigMatchCell")
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: "NewsCell")
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchBigMatches() {
        Firestore.firestore().collection("bigmatches").order(by: "datetime").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.bigMatches = documents.compactMap { doc in
                let data = doc.data()
                guard let league = data["league"] as? String,
                      let match = data["match"] as? String,
                      let stadium = data["stadium"] as? String,
                      let timestamp = data["datetime"] as? Timestamp else { return nil }
                
                let url = data["url"] as? String ?? ""
                
                return BigMatch(
                    id: doc.documentID,
                    league: league,
                    match: match,
                    stadium: stadium,
                    datetime: timestamp.dateValue(),
                    url: url
                )
            }
            self.collectionView.reloadData()
        }
    }
    
    private func fetchLatestNews() {
        Firestore.firestore()
            .collection("news")
            .order(by: "date", descending: true)
            .limit(to: 4) // 최신 4개만
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.newsList = documents.compactMap {
                    let data = $0.data()
                    return News(
                        title: data["title"] as? String ?? "",
                        source: data["source"] as? String ?? "",
                        url: data["url"] as? String ?? ""
                    )
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
    }
}

extension HomeVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? bigMatches.count : newsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BigMatchCell", for: indexPath) as! HomeBigMatchCell
            let match = bigMatches[indexPath.item]
            let display = "\(match.league): \(match.match)\n\(match.stadium)\n\(formattedDate(match.datetime))"
            cell.configure(with: display)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCell
            cell.configure(with: newsList[indexPath.item])
            return cell
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(E) HH:mm"
        return formatter.string(from: date)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "HeaderView",
                                                                     for: indexPath) as! SectionHeaderView
        header.setTitle(indexPath.section == 0 ? "🔥 빅매치" : "📰 뉴스")
        
        if indexPath.section == 1 {
            header.showMoreButton(true)
            header.onMoreTapped = { [weak self] in
                let newsVC = AllNewsListVC()
                self?.navigationController?.pushViewController(newsVC, animated: true)
            }
        } else {
            header.showMoreButton(false)
        }
        
        return header
    }
    
    @objc private func openInstagram() {
        if let url = URL(string: "https://www.instagram.com/gugchugyeojido/") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let match = bigMatches[indexPath.item]
            if let url = URL(string: match.url), !match.url.isEmpty {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
            }
        } else if indexPath.section == 1 {
            
            let news = newsList[indexPath.item]
            if let url = URL(string: news.url) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
            }
        }
    }
}
