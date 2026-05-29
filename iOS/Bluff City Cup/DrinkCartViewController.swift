//
//  DrinkCartViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit
import MessageUI

@objc
protocol DrinkCartViewControllerDelegate {
    
    @objc optional func toggleTopPanelDrinkCart()
    @objc optional func collapseTopPanelDrinkCart()
    @objc optional func changeViewDrinkCart(_ menu: String)
    @objc optional func handlePanGesture(_ recognizer: UIPanGestureRecognizer)
    
}

class DrinkCartViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var delegate: DrinkCartViewControllerDelegate?
    
    var match: Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        drinkCartButton.layer.cornerRadius = 8
        drinkCartButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func drinkCartRequested(_ sender: AnyObject) {
        
        /*
        let alert = UIAlertController(title: "Don't Worry!", message: "Beers are on the way.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)*/
        DispatchQueue.main.async {
            if !MFMessageComposeViewController.canSendText() {
                print("COnnot Send text")
                
                let alert = UIAlertController(title: "Sorry!", message: "You are unable to send a request", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let messageVC = MFMessageComposeViewController()
                if self.match != nil {
                    messageVC.body = User.sharedInstance.getName() + " is requesting beers on hole " + String(self.match.getCurrentHole()) + "."
                }
                else {
                    messageVC.body = User.sharedInstance.getName() + " is requesting beers. Please text back this number for their location."
                }
                
                messageVC.recipients = [Model.sharedInstance.getTournament().getDrinkCartNumber()!]
                messageVC.messageComposeDelegate = self
                
                self.present(messageVC, animated: false, completion: nil)
                
            }
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.cancelled :
            print("message canceled")
            
        case MessageComposeResult.failed :
            print("message failed")
            
        case MessageComposeResult.sent :
            print("message sent")
            
        }
        controller.dismiss(animated: true, completion: nil)
    }

    
    @IBOutlet weak var drinkCartButton: UIButton!
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        
        delegate?.toggleTopPanelDrinkCart?()
        
        
        
    }
    
    @IBAction func panHandle(_ sender: UIPanGestureRecognizer) {
        delegate?.handlePanGesture?(sender)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    
    
}

extension DrinkCartViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelDrinkCart?()
        delegate?.changeViewDrinkCart?(menu)
    }
}
