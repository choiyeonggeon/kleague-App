//
//  TeamVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/12/25.
//

import UIKit
import SafariServices

class TeamVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    
    struct Team {
        let name: String
        let ticketURL: String
    }
    
    let teams: [Team] = [
        Team(name: "수원",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS003"),
        Team(name: "강원",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS014"),
        Team(name: "성남",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS093"),
        Team(name: "인천",
             ticketURL: "https://www.incheonutd.com/ticket/ticket_intro.php"),
        Team(name: "수원FC",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS061"),
        Team(name: "전남",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS011")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "예매하기"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = teams[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = teams[indexPath.row]
        
        // 웹 예매 상세 페이지 열기 (추천)
        if let url = URL(string: team.ticketURL) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
