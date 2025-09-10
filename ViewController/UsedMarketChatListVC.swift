//
//  UsedMarketChatListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 9/8/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class UsedMarketChatListVC: UIViewController {

    private let tableView = UITableView()
    private let db = Firestore.firestore()
    private var chatRooms: [ChatRoom] = []
    private var unreadCounts: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchChatRooms()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "채팅"

        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func fetchChatRooms() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("chatRooms")
            .whereField("participants", arrayContains: uid)
            .order(by: "lastUpdatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }

                self.chatRooms = snapshot?.documents.compactMap { doc -> ChatRoom? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let participants = data["participants"] as? [String] else { return nil }

                    let lastMessage = data["lastMessage"] as? String
                    let lastUpdatedAt: Date?
                    if let ts = data["lastUpdatedAt"] as? Timestamp {
                        lastUpdatedAt = ts.dateValue()
                    } else {
                        lastUpdatedAt = nil
                    }

                    self.fetchUnreadCount(for: doc.documentID, currentUserId: uid)

                    return ChatRoom(id: doc.documentID,
                                    title: title,
                                    participants: participants,
                                    lastMessage: lastMessage,
                                    lastUpdatedAt: lastUpdatedAt)
                } ?? []

                DispatchQueue.main.async { self.tableView.reloadData() }
            }
    }

    private func fetchUnreadCount(for chatRoomId: String, currentUserId: String) {
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
//            .whereField("readBy", arrayContainsNot: currentUserId) // Firebase에 arrayContainsNot는 없으므로 나중에 필터링 필요
            .getDocuments { [weak self] snapshot, _ in
                let count = snapshot?.documents.count ?? 0
                self?.unreadCounts[chatRoomId] = count
                DispatchQueue.main.async { self?.tableView.reloadData() }
            }
    }
}

extension UsedMarketChatListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatRoomCell.identifier,
            for: indexPath
        ) as! ChatRoomCell

        let room = chatRooms[indexPath.row]
        let unreadCount = unreadCounts[room.id] ?? 0
        cell.configure(with: room, unreadCount: unreadCount)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let room = chatRooms[indexPath.row]
        let chatDetailVC = ChatVC(chatRoom: room, currentUserId: currentUserId)
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}
