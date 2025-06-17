//
//  CheeringSongDetailVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/13/25.
//

import WebKit
import SnapKit

class CheeringSongDetailVC: UIViewController {
    
    let webView = WKWebView()
    let titleLabel = UILabel()
    let lyricsLabel = UILabel()
    let song: CheeringSong
    
    init(song: CheeringSong) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = song.title
        setDetailUI()
        loadYoutube()
    }
    
    func setDetailUI() {
        view.addSubview(titleLabel)
        view.addSubview(lyricsLabel)
        view.addSubview(webView)
        
        titleLabel.text = song.title
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        lyricsLabel.text = song.lyrics
        lyricsLabel.numberOfLines = 0
        lyricsLabel.textAlignment = .center
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        lyricsLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        webView.snp.makeConstraints {
            $0.top.equalTo(lyricsLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
    }
    
    func loadYoutube() {
        guard let id = extractVideoID(from: song.youtubeURL),
              let url = URL(string: "https://www.youtube.com/embed/\(id)") else { return }
        webView.load(URLRequest(url: url))
    }
    
    func extractVideoID(from urlString: String) -> String? {
        if let queryItems = URLComponents(string: urlString)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        } else if urlString.contains("youtu.be") {
            return URL(string: urlString)?.lastPathComponent
        }
        return nil
    }
}
