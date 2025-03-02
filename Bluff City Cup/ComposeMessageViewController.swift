//
//  ComposeMessageViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague
//  Copyright © 2024 Jumpstop Creations. All rights reserved.
//

import UIKit
import PhotosUI

protocol ComposeMessageViewControllerDelegate: AnyObject {
    func messagePosted()
}

class ComposeMessageViewController: UIViewController {
    
    weak var delegate: ComposeMessageViewControllerDelegate?
    var tournament: Tournament!
    var user: User!
    
    private let textView = UITextView()
    private let imageView = UIImageView()
    private var selectedImage: UIImage?
    private let model = Model.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postTapped))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        let addImageButton = UIButton(type: .system)
        addImageButton.setTitle("Add Image", for: .normal)
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(addImageButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.heightAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func postTapped() {
        guard !textView.text.isEmpty else { return }
        
        let type: MessageType = selectedImage != nil ? .image : .text
        let message = Message(id: 0, 
                            userIdentifier: user.getIdentifier(),
                            content: textView.text,
                            type: type)
        
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
            model.postMessage(tournamentName: tournament.getName(), message: message, imageData: imageData) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.delegate?.messagePosted()
                        self?.dismiss(animated: true)
                    } else {
                        // Show error
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Unknown error", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        } else {
            model.postMessage(tournamentName: tournament.getName(), message: message) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.delegate?.messagePosted()
                        self?.dismiss(animated: true)
                    } else {
                        // Show error
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Unknown error", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func addImageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ComposeMessageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                guard let image = image as? UIImage else { return }
                self?.selectedImage = image
                self?.imageView.image = image
                self?.imageView.isHidden = false
            }
        }
    }
}
