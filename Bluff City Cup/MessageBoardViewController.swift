//
//  MessageBoardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague
//  Copyright 2024 Jumpstop Creations. All rights reserved.
//

import UIKit
import AVFoundation

protocol MessageBoardViewControllerDelegate: AnyObject {
    func toggleTopPanelMessageBoard()
    func collapseTopPanelMessageBoard()
    func changeViewMessageBoard(_ menu: String)
}

class MessageBoardViewController: UIViewController {
    
    weak var delegate: MessageBoardViewControllerDelegate?
    var user: User!
    var tournament: Tournament!
    let model = Model.sharedInstance
    
    private var messages: [Message] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let messageInputBar = UIView()
    private let messageTextField = UITextField()
    private let addMediaButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    
    private var selectedMedia: (type: MediaType, content: Any)?
    private var messageInputBarHeightConstraint: NSLayoutConstraint?
    private let thumbnailImageView = UIImageView()
    private let removeMediaButton = UIButton(type: .system)
    
    private enum MediaType {
        case image
        case video
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup table view first
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        view.addSubview(tableView)
        
        // Add header container
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.059, green: 0.161, blue: 0.420, alpha: 1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Add menu button
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(menuButton)
        
        // Add title label
        let titleLabel = UILabel()
        titleLabel.text = "Message Board"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Setup message input bar
        messageInputBar.backgroundColor = .systemBackground
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.layer.borderWidth = 0.5
        view.addSubview(messageInputBar)
        
        // Add height constraint for messageInputBar
        messageInputBarHeightConstraint = messageInputBar.heightAnchor.constraint(equalToConstant: 60)
        messageInputBarHeightConstraint?.isActive = true

        // Setup thumbnail in messageTextField
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 4
        thumbnailImageView.isHidden = true
        messageTextField.addSubview(thumbnailImageView)

        // Setup remove button
        removeMediaButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeMediaButton.tintColor = .systemGray
        removeMediaButton.translatesAutoresizingMaskIntoConstraints = false
        removeMediaButton.addTarget(self, action: #selector(removeMediaTapped), for: .touchUpInside)
        removeMediaButton.isHidden = true
        messageTextField.addSubview(removeMediaButton)

        // Add constraints for thumbnail and remove button
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: messageTextField.leadingAnchor, constant: 8),
            thumbnailImageView.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 30),
            thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor),

            removeMediaButton.centerYAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            removeMediaButton.centerXAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            removeMediaButton.widthAnchor.constraint(equalToConstant: 20),
            removeMediaButton.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Setup text field
        messageTextField.placeholder = "Message"
        messageTextField.backgroundColor = .systemGray6
        messageTextField.layer.cornerRadius = 18
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        messageTextField.leftViewMode = .always
        messageTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        messageTextField.rightViewMode = .always
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.addSubview(messageTextField)
        
        // Setup send button
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        messageInputBar.addSubview(sendButton)
        
        // Setup media button
        addMediaButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addMediaButton.tintColor = .systemBlue
        addMediaButton.translatesAutoresizingMaskIntoConstraints = false
        addMediaButton.addTarget(self, action: #selector(addMediaTapped), for: .touchUpInside)
        messageInputBar.addSubview(addMediaButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Header constraints
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            menuButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            menuButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            
            // Message input bar constraints
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addMediaButton.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 8),
            addMediaButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            addMediaButton.widthAnchor.constraint(equalToConstant: 30),
            addMediaButton.heightAnchor.constraint(equalToConstant: 30),
            
            messageTextField.leadingAnchor.constraint(equalTo: addMediaButton.trailingAnchor, constant: 8),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 36),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    @objc private func refreshMessages() {
        loadMessages()
    }
    
    private func loadMessages() {
        print("Loading messages for tournament: \(tournament.getName())")
        model.fetchMessages(tournamentName: tournament.getName()) { [weak self] messages, error in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                
                if let error = error {
                    print("Error loading messages: \(error)")
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                if let messages = messages {
                    print("Received \(messages.count) messages")
                    self?.messages = messages.sorted(by: { $0.getTimestamp() > $1.getTimestamp() })
                    self?.tableView.reloadData()
                    
                    // Only scroll if we have messages
                    if let messageCount = self?.messages.count, messageCount > 0 {
                        let lastIndex = IndexPath(row: messageCount - 1, section: 0)
                        self?.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                    }
                }
            }
        }
    }
    
    @objc private func addMediaTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    @objc private func menuButtonTapped() {
        delegate?.toggleTopPanelMessageBoard()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    @objc private func sendMessage() {
        if let selectedMedia = selectedMedia {
                switch selectedMedia.type {
                case .image:
                    guard let image = selectedMedia.content as? UIImage,
                          let imageData = image.jpegData(compressionQuality: 0.7) else { return }
                    
                    // Use existing postMessage function with image data
                    let message = Message(id: 0,
                                        userIdentifier: user.getIdentifier(),
                                        content: "",  // Server will handle the content
                                        type: .image)
                    
                    model.postMessage(tournamentName: tournament.getName(), message: message, imageData: imageData) { [weak self] success, error in
                        DispatchQueue.main.async {
                            if success {
                                // Clear the media preview
                                self?.selectedMedia = nil
                                self?.thumbnailImageView.isHidden = true
                                self?.removeMediaButton.isHidden = true
                                self?.messageInputBarHeightConstraint?.constant = 60
                                
                                UIView.animate(withDuration: 0.3) {
                                    self?.view.layoutIfNeeded()
                                }
                                
                                // Reset text field left padding
                                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
                                self?.messageTextField.leftView = paddingView
                                self?.messageTextField.leftViewMode = .always
                                
                                self?.loadMessages()
                            } else {
                                let alert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Failed to send image", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(alert, animated: true)
                            }
                        }
                    }
                    
                case .video:
                    guard let videoURL = selectedMedia.content as? URL else { return }
                    // TODO: Implement video upload to server
                    print("Uploading video from URL: \(videoURL)")
                }
                return
            }

        
        // Existing text message sending logic remains the same
        guard let content = messageTextField.text, !content.isEmpty else { return }
        
        let message = Message(id: 0,
                             userIdentifier: user.getIdentifier(),
                             content: content,
                             type: .text)
        
        model.postMessage(tournamentName: tournament.getName(), message: message) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.messageTextField.text = ""
                    self?.loadMessages()
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Failed to send message", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func removeMediaTapped() {
        selectedMedia = nil
        thumbnailImageView.isHidden = true
        removeMediaButton.isHidden = true
        messageInputBarHeightConstraint?.constant = 60  // Reset height when media removed
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Reset text field left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        messageTextField.leftView = paddingView
        messageTextField.leftViewMode = .always
    }

    private func generateThumbnail(from videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
}

extension MessageBoardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell at index \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        let isCurrentUser = message.getUserIdentifier() == user.getIdentifier()
        print("Message content: \(message.getContent())")
        cell.configure(with: message, isCurrentUser: isCurrentUser)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension MessageBoardViewController: ComposeMessageViewControllerDelegate {
    func messagePosted() {
        loadMessages()
    }
}

// MARK: - Message Cell
class MessageCell: UITableViewCell {
    private let messageView = UIView()
    private let contentLabel = UILabel()
    private let initialsLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageImageView = UIImageView()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Configure views
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.layer.cornerRadius = 16
        messageView.clipsToBounds = true
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.numberOfLines = 0
        
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        initialsLabel.textColor = .secondaryLabel
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .secondaryLabel
        
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFit
        messageImageView.clipsToBounds = true
        messageImageView.isHidden = true
        messageView.addSubview(messageImageView)
        
        // Add views to hierarchy
        contentView.addSubview(messageView)
        messageView.addSubview(contentLabel)
        contentView.addSubview(initialsLabel)
        contentView.addSubview(timeLabel)
        
        // These constraints will never change
        NSLayoutConstraint.activate([
            messageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            contentLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -12),
            contentLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            messageImageView.topAnchor.constraint(equalTo: messageView.topAnchor),
                messageImageView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
                messageImageView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
                messageImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }

    func configure(with message: Message, isCurrentUser: Bool) {
        
        if message.getType() == .image {
            contentLabel.isHidden = true
            messageImageView.isHidden = false
            
            if message.getMediaUrl() != nil,
               let url = URL(string: message.getMediaUrl()!) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.messageImageView.image = image
                        }
                    }
                }.resume()
            } else {
                print("Invalid image URL")
                messageImageView.image = nil
            }
        } else {
            contentLabel.isHidden = false
            messageImageView.isHidden = true
            contentLabel.text = message.getContent()
        }
        
        // Configure content
        contentLabel.text = message.getContent()
        messageView.backgroundColor = isCurrentUser ? .systemBlue : .systemGray5
        
        contentLabel.textColor = isCurrentUser ? .white : .black
        
        // Remove only alignment constraints
        if let constraints = contentView.constraints.filter({ $0.firstAttribute == .leading || $0.firstAttribute == .trailing }).first {
            constraints.isActive = false
        }
        
        if isCurrentUser {
            // Right align for current user
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            timeLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor).isActive = true
            initialsLabel.isHidden = true
        } else {
            // Left align for other users
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            timeLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor).isActive = true
            initialsLabel.isHidden = false
            initialsLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor).isActive = true
            initialsLabel.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: -4).isActive = true
        }
        
        // Format and show timestamp
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.getTimestamp())
        
        // Set initial placeholder
        initialsLabel.text = "--"
        
        // Fetch user information
        Model.sharedInstance.fetchUserInfo(identifier: message.getUserIdentifier()) { firstName, lastName, email, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print("Error fetching user info: \(error)")
                    return
                }
                
                let firstInitial = firstName?.prefix(1) ?? "-"
                let lastInitial = lastName?.prefix(1) ?? "-"
                self?.initialsLabel.text = "\(firstInitial)\(lastInitial)"
            }
        }
    }
}

extension MessageBoardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let image = info[.originalImage] as? UIImage {
                selectedMedia = (.image, image)
                thumbnailImageView.image = image
                thumbnailImageView.isHidden = false
                removeMediaButton.isHidden = false
                messageInputBarHeightConstraint?.constant = 100  // Increase height when image selected
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                // Update text field left padding
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 0))
                messageTextField.leftView = paddingView
                messageTextField.leftViewMode = .always
                
            } else if let videoURL = info[.mediaURL] as? URL {
                selectedMedia = (.video, videoURL)
                if let thumbnail = generateThumbnail(from: videoURL) {
                    thumbnailImageView.image = thumbnail
                    thumbnailImageView.isHidden = false
                    removeMediaButton.isHidden = false
                    
                    // Update text field left padding
                    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 0))
                    messageTextField.leftView = paddingView
                    messageTextField.leftViewMode = .always
                }
            }
        }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
