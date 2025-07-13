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
        Team(name: "강원",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS014"),
        Team(name: "경남",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/88"),
        Team(name: "김포",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/493"),
        Team(name: "대구",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/84"),
        Team(name: "부산",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/82"),
        Team(name: "부천",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS067"),
        Team(name: "FC서울",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/65"),
        Team(name: "서울E",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/85"),
        Team(name: "수원",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS003"),
        Team(name: "성남",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS093"),
        Team(name: "수원FC",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS061"),
        Team(name: "안양",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/86"),
        Team(name: "울산",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/66"),
        Team(name: "인천",
             ticketURL: "https://www.incheonutd.com/ticket/ticket_intro.php"),
        Team(name: "전남",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS011"),
        Team(name: "대전(자사앱 이용 바람.)",
             ticketURL: ""),
        Team(name: "전북",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/73"),
        Team(name: "제주SK",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/76"),
        Team(name: "천안",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS006"),
        Team(name: "충북청주",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS173"),
        Team(name: "충남아산",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS113"),
        Team(name: "포항",
             ticketURL: "https://www.ticketlink.co.kr/sports/138/74"),
        Team(name: "화성",
             ticketURL: "https://ticket.interpark.com/m-ticket/Sports/GoodsInfo?SportsCode=07002&TeamCode=PS197")
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
        
        if let url = URL(string: team.ticketURL) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
