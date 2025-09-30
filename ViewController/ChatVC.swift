//
//  ChatVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/20/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ChatVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let chatRoom: ChatRoom
    private let currentUserId: String
    
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let addButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    private var listener: ListenerRegistration?
    
    // bottom constraint 저장용
    private var messageInputViewBottomConstraint: Constraint?
    
    init(chatRoom: ChatRoom, currentUserId: String) {
        self.chatRoom = chatRoom
        self.currentUserId = currentUserId
        super.init(nibName: nil, bundle: nil)
        self.title = "\(chatRoom.title) 채팅"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        listenMessages()
        
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0) // 입력창 높이만큼 inset
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - UI 세팅
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        
        messageInputView.addSubview(addButton)
        messageInputView.addSubview(messageTextField)
        messageInputView.addSubview(sendButton)
        
        // 테이블뷰
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(messageInputView.snp.top)
        }
        
        // 메시지 입력창
        messageInputView.backgroundColor = .secondarySystemBackground
        messageInputView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(60)
            messageInputViewBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        addButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        // 메시지 텍스트필드
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "메시지를 입력하세요."
        messageTextField.snp.makeConstraints {
            $0.left.equalTo(addButton.snp.right).offset(8)
            $0.centerY.equalToSuperview()
            $0.right.equalTo(sendButton.snp.left).offset(-8)
            $0.height.equalTo(40)
        }
        
        // 전송 버튼
        sendButton.setTitle("전송", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - 키보드 처리
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        messageInputViewBottomConstraint?.update(offset: -keyboardHeight)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.tableView.contentInset.bottom = keyboardHeight
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        messageInputViewBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.tableView.contentInset.bottom = 0
            self.tableView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - 메시지 수신
    private func listenMessages() {
        let db = Firestore.firestore()
        listener = db.collection("used_market")
            .document(chatRoom.id)
            .collection("chats")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { ChatMessage.fromDict(data: $0.data(), id: $0.documentID) }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
    }
    
    // MARK: - 메시지 전송
    @objc private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        let db = Firestore.firestore()
        
        let messageData: [String: Any] = [
            "text": text,
            "senderId": currentUserId,
            "createdAt": Timestamp()
        ]
        
        db.collection("used_market")
            .document(chatRoom.id)
            .collection("chats")
            .addDocument(data: messageData) { _ in
                DispatchQueue.main.async {
                    self.scrollToBottom()
                }
            }
        
        messageTextField.text = ""
    }
    
    // MARK: - 스크롤 이동
    private func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - 이미지 선택
    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("chat_images/\(chatRoom.id)/\(fileName)")
        
        storageRef.putData(imageData) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, _ in
                guard let url = url else { return }
                self.sendImageMessage(url.absoluteString)
            }
        }
    }
    
    private func sendImageMessage(_ imageUrl: String) {
        let db = Firestore.firestore()
        let messageData: [String: Any] = [
            "imageUrl": imageUrl,
            "senderId": currentUserId,
            "createdAt": Timestamp()
        ]
        db.collection("used_market")
            .document(chatRoom.id)
            .collection("chats")
            .addDocument(data: messageData)
    }
}

// MARK: - UITableViewDataSource
extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let msg = messages[indexPath.row]
        let isCurrentUser = (msg.senderId == currentUserId)
        cell.configure(with: msg, isCurrentUser: isCurrentUser)
        return cell
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
