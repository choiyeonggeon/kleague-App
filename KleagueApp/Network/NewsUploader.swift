////
////  NewsUploader.swift
////  KleagueApp
////
////  Created by 최영건 on 10/2/25.
////
//
//import Foundation
//import FirebaseFirestore
//
//struct News {
//    let title: String
//    let source: String
//    let url: String
//}
//
//class NewsUploader {
//    
//    // XMLParserDelegate 기반 RSSParser 필요
//    private let parser = RSSParser() // 구현된 RSSParser
//    
//    func fetchAndUploadRSS(completion: @escaping () -> Void) {
//        let rssUrl = "https://sports.news.naver.com/kfootball/rss"
//        guard let url = URL(string: rssUrl) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            guard let data = data else { return }
//            
//            let xmlParser = XMLParser(data: data)
//            xmlParser.delegate = self.parser
//            xmlParser.parse()
//            
//            let firestore = Firestore.firestore()
//            let group = DispatchGroup()
//            
//            for news in self.parser.newsItems {
//                group.enter()
//                firestore.collection("news")
//                    .document(news.title) // 중복 방지
//                    .setData([
//                        "title": news.title,
//                        "source": news.source,
//                        "url": news.url,
//                        "date": Timestamp(date: Date()) // Timestamp로 저장
//                    ]) { _ in
//                        group.leave()
//                    }
//            }
//            
//            group.notify(queue: .main) {
//                completion() // 모든 업로드 완료 시 콜백
//            }
//            
//        }.resume()
//    }
//}
//
