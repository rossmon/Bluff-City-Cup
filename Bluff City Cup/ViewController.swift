//
//  ViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/12/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit
import CloudKit

protocol ViewControllerDelegate {
    func loggedIn(tournamentName: String)
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var delegate: ViewControllerDelegate?
    
    var activeTextField = UITextField()
    
    //@IBOutlet weak var activityView: UIView!
    let framing = UIScreen.main.bounds
    
    let model: Model = Model.sharedInstance
    let user: User = User.sharedInstance
    var userName: String!
    
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    var pickOption = [(name: String, commish: String)]()
    
    @IBOutlet weak var tournamentPassword: UITextField!
    @IBOutlet weak var tournamentAddPasswordView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var tournamentDetailsView: UIView!
    
    @IBOutlet weak var tournamentNameField: UITextField!
    @IBOutlet weak var tournamentPasswordField: UITextField!
    @IBOutlet weak var organizerNameField: UITextField!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIApplication.shared.statusBarStyle = .lightContent
        //activityView.isHidden = true
        //activityView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        //activityView.clipsToBounds = true
        //activityView.layer.cornerRadius = 10
        
        tournamentNameTextField.delegate = self
        
        blurView.isHidden = true
        tournamentAddPasswordView.isHidden = true
        tournamentAddPasswordView.layer.cornerRadius = 8.0
        tournamentAddPasswordView.clipsToBounds = true
        
        tournamentDetailsView.isHidden = true
        tournamentDetailsView.layer.cornerRadius = 8.0
        tournamentDetailsView.clipsToBounds = true
        
        pickerView.isHidden = true
        tournamentNameTextField.isHidden = true
        loginButton.isHidden = true
        pickerView.delegate = self
        
        firstNameField.isHidden = true
        firstNameField.delegate = self
        lastNameField.isHidden = true
        lastNameField.delegate = self
        
        let defaults = UserDefaults.standard
        
        userName = defaults.object(forKey: "UserName") as? String
        
        if userName == nil || userName == "" || userName == " " {
            /*
             model.getUserInfo() { (result, error) in
             if error != nil {
             self.errorAlert(error)
             }
             else {
             if result == nil {
             
             defaults.set(self.user.getName(), forKey: "UserName")
             self.userName = self.user.getName()
             
             
             self.model.getTournamentNames() { tournaments in
             self.pickOption = tournaments
             
             DispatchQueue.main.async {
             self.tournamentNameTextField.isHidden = false
             self.loginButton.isHidden = false
             }
             
             
             }
             }
             else if result == "Upgrade" {
             self.upgradeiOSAlert()
             }
             else if result == "iCloud Login" {
             self.iCloudLoginAlert()
             }
             else if result == "No User" {
             self.noUserError()
             }
             else if result == "User ID" {
             self.noUserIDError()
             }
             else {
             if let error = result {
             self.catchAllError(error)
             }
             else {
             self.catchAllError("")
             }
             }
             }
             }
             */
            model.getTournamentNames() { tournaments in
                self.pickOption = tournaments
                print(self.pickOption.count)
                
                DispatchQueue.main.async {
                    self.tournamentNameTextField.isHidden = false
                    self.loginButton.isHidden = false
                    self.firstNameField.isHidden = false
                    self.lastNameField.isHidden = false
                }
            }
            
        }
        else {
            model.getTournamentNames() { tournaments in
                self.pickOption = tournaments
                print(self.pickOption.count)
                
                DispatchQueue.main.async {
                    self.tournamentNameTextField.isHidden = false
                    self.loginButton.isHidden = false
                }
            }
        }
        
        //userName = "Rachel Montague"
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    @IBAction func backgroundTouched(_ sender: Any) {
       
            view.endEditing(true)
        view.resignFirstResponder()
        pickerView.isHidden = true
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tournamentNameTextField.text = pickOption[row].name
        pickerView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tournamentFieldSelected(_ sender: UITextField) {
        
        self.view.endEditing(true)
        
        pickerView.isHidden = false
        pickerView.reloadAllComponents()
    }
    @IBOutlet weak var tournamentNameTextField: UITextField!
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        
        
        
        print(userName)
        
        let defaults = UserDefaults.standard
        
        if (self.firstNameField.text == "" || self.lastNameField.text == "" || self.firstNameField.text == nil || self.lastNameField.text == nil) && (userName == nil || userName == "" || userName == " "){
            nameInvalidAlert()
        }
        else if self.tournamentNameTextField.text == nil || self.tournamentNameTextField.text == "" {
            tournamentInvalidAlert()
        }
        else {
            
            
            if pickOption.count == 0 {
                noTournamentAlert()
            }
            else if self.userName == nil && (self.firstNameField.text == "" || self.lastNameField.text == "" || self.firstNameField.text == nil || self.lastNameField.text == nil) {
                nameInvalidAlert()
            }
            else {
                startActivity()
                
                if self.userName == nil || self.userName == "" || self.userName == " " {
                    self.user.setUserName(self.firstNameField.text! + " " + self.lastNameField.text!)
                    
                    self.userName = self.user.getName()
                }
                
    
                var checkTournamentResults: (found: Bool, commissioner: String, commissionerPassword: String)?
                model.checkTournament(tournamentName: tournamentNameTextField.text!) { isFound, commishName, commishPassword in
                    checkTournamentResults = (isFound,commishName,commishPassword)
                    
                    if checkTournamentResults!.found {
                        
                        var checkUserResults: (found: Bool, player: Player?, inCurrentMatch: Bool)?
                        self.model.checkUser(userName: self.userName, tournamentName: self.tournamentNameTextField.text!) {
                            playerisFound, playerFound, isInCurrentMatch in
                            
                            checkUserResults = (found: playerisFound, player: playerFound, inCurrentMatch: isInCurrentMatch)
                            if checkUserResults!.found {
                                
                                if self.userName == checkTournamentResults!.commissioner {
                                    
                                    self.model.checkScorekeeper(userName: self.userName, tournamentName: self.tournamentNameTextField.text!) { isScorekeeper, isInMatch in
                    
                                        self.checkCommissionerPassword(checkTournamentResults!.commissionerPassword) { correct in
                                            if correct {
                                                if isScorekeeper {
                                                    self.user.setUser(name: self.userName, player: checkUserResults!.player!,role: "Commissioner", scorekeeper: true, isInMatch: isInMatch)
                                                    defaults.set(true, forKey: "Scorekeeper")
                                                }
                                                else {
                                                    self.user.setUser(name: self.userName, player: checkUserResults!.player!,role: "Commissioner", scorekeeper: false, isInMatch: isInMatch)
                                                    defaults.set(false, forKey: "Scorekeeper")
                                                }
                                                defaults.set("Commissioner", forKey: "UserRole")
                                                print("Commissioner found")
                                                
                                                
                                                
                                                defaults.set(self.tournamentNameTextField.text!, forKey: "TournamentName")
                                                defaults.set(self.user.getName(), forKey: "UserName")
                                                
                                                self.delegate?.loggedIn(tournamentName: self.tournamentNameTextField.text!)
                                            }
                                            else {
                                                self.incorrectPasswordAlert()
                                                
                                            }
                                        }
                                    }
                                }
                                    
                                else {
                                    self.model.checkScorekeeper(userName: self.userName, tournamentName: self.tournamentNameTextField.text!) { isScorekeeper, inMatch in
                                        
                                        if isScorekeeper {
                                            self.user.setUser(name: self.userName, player: checkUserResults!.player!,role: "Scorekeeper", scorekeeper: true, isInMatch: inMatch)
                                            defaults.set("Scorekeeper", forKey: "UserRole")
                                            defaults.set(true, forKey: "Scorekeeper")
                                            print("Scorekeeper found")
                                        }
                                        else {
                                            if (checkUserResults?.inCurrentMatch)! {
                                                self.user.setUser(name: self.userName, player: checkUserResults!.player!,role: "Player", scorekeeper: false, isInMatch: inMatch)
                                                defaults.set("Player", forKey: "UserRole")
                                                defaults.set(false, forKey: "Scorekeeper")
                                                print("Player found")
                                            }
                                            else {
                                                self.user.setUser(name: self.userName, player: checkUserResults!.player!,role: "Spectator", scorekeeper: false, isInMatch: inMatch)
                                                defaults.set("Spectator", forKey: "UserRole")
                                                defaults.set(false, forKey: "Scorekeeper")
                                                print("Player spectator found")
                                            }
                                        }
                                        
                                        
                                        
                                        defaults.set(self.tournamentNameTextField.text!, forKey: "TournamentName")
                                        defaults.set(self.user.getName(), forKey: "UserName")
                                        
                                        self.delegate?.loggedIn(tournamentName: self.tournamentNameTextField.text!)
                                        
                                    }
                                }
                            }
                            else {
                                print("No Player")
                                if self.user.getName() == checkTournamentResults?.commissioner {
                                    self.checkCommissionerPassword(checkTournamentResults!.commissionerPassword) { correct in
                                        if correct {
                                            print("FOUND COMMISSIONER")
                                            defaults.set(false, forKey: "Scorekeeper")
                                            defaults.set("Commissioner", forKey: "UserRole")
                                            print("Commissioner found")
                                            defaults.set(self.tournamentNameTextField.text!, forKey: "TournamentName")
                                            defaults.set(self.user.getName(), forKey: "UserName")
                                            
                                            self.user.setUser(name: self.user.getName() , player: Player(),role: "Commissioner", scorekeeper: false, isInMatch: false)
                                            
                                            self.delegate?.loggedIn(tournamentName: self.tournamentNameTextField.text!)
                                        }
                                        else {
                                            self.incorrectPasswordAlert()
                                            
                                        }
                                    }
                                    
                                }
                                else {
                                    self.handleNoPlayer(userName: self.userName)
                                }
                            }
                        }
                    }
                    else {
                        self.noTournamentRecordAlert()
                    }
                }
            }
        }
        
    }
    
    @IBAction func addTournamentPressed(_ sender: Any) {
        blurView.isHidden = false
        tournamentAddPasswordView.isHidden = false
        
    }
    
    @IBAction func tournamentCancelPressed(_ sender: Any) {
        
        blurView.isHidden = true
        tournamentAddPasswordView.isHidden = true
        
        tournamentPassword.text = ""
    }
    
    @IBAction func tournamentEnterPressed(_ sender: Any) {
        
        self.model.checkCreatePassword(tournamentPassword.text!) { isValid in
            if isValid {
                DispatchQueue.main.async {
                    self.tournamentAddPasswordView.isHidden = true
                    
                    self.tournamentPassword.text = ""
                    self.tournamentDetailsView.isHidden = false
                }
            }
            else {
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Oops!", message: "The entered password is not valid.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        /*
        if tournamentPassword.text == "mitchell" {
            tournamentAddPasswordView.isHidden = true
           
            tournamentPassword.text = ""
            tournamentDetailsView.isHidden = false
        }
        else {
            let alert = UIAlertController(title: "Oops!", message: "The entered password is not valid.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
        }
         */
    }
    
    @IBAction func newTournamentCancel(_ sender: Any) {
        
        blurView.isHidden = true
        tournamentDetailsView.isHidden = true
        
    }
    
    
    @IBAction func newTournamentEnter(_ sender: Any) {
        
        if tournamentNameField.text != "" && tournamentPasswordField.text != "" && organizerNameField.text != "" {
            Model.sharedInstance.updateTournament(Tournament(name:tournamentNameField.text! ,password: tournamentPasswordField.text! ,owner: organizerNameField.text!), {
                
                self.model.getTournamentNames() { tournaments in
                    self.pickOption = tournaments
                    print(self.pickOption.count)
                    
                    DispatchQueue.main.async {
                        self.tournamentDetailsView.isHidden = true
                        self.blurView.isHidden = true
                        self.tournamentNameTextField.isHidden = false
                        self.loginButton.isHidden = false
                    }
                }
                
            })
        }
        else {
            let alert = UIAlertController(title: "Oops!", message: "Please enter all fields.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    func checkCommissionerPassword(_ commishPassword: String, _ completion: @escaping (_ correct: Bool) -> Void) {
        
        DispatchQueue.main.async {
            var inputTextField: UITextField?
            let passwordPrompt = UIAlertController(title: "Security!", message: "Enter commish password:", preferredStyle: UIAlertController.Style.alert)
            passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            passwordPrompt.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                // Now do whatever you want with inputTextField (remember to unwrap the optional)
                
                if inputTextField?.text! == commishPassword {
                    completion(true)
                }
                else {
                    completion(false)
                }
                
            }))
            passwordPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                inputTextField = textField
            })
            
            self.present(passwordPrompt, animated: true, completion: nil)
        }
    }
    
    
    func startActivity() {
        DispatchQueue.main.async {
            //self.activityView.isHidden = false
            self.loadIndicator.startAnimating()
        }
    }
    
    func stopActivity() {
        DispatchQueue.main.async {
            //self.activityView.isHidden = true
            self.loadIndicator.stopAnimating()
        }
    }
    
    func noTournamentAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let endMatchAlert = UIAlertController(title: "Oops!", message: "There are no tournament records.", preferredStyle: UIAlertController.Style.alert)
            
            endMatchAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                
                self.tournamentNameTextField.text = nil
            }))
            
            self.present(endMatchAlert, animated: true, completion: nil)
        }
    }
    func nameInvalidAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let nameInvalidAlert = UIAlertController(title: "Oops!", message: "Please enter a first and last name.", preferredStyle: UIAlertController.Style.alert)
            
            nameInvalidAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                
                // self.tournamentNameTextField.text = nil
            }))
            
            self.present(nameInvalidAlert, animated: true, completion: nil)
        }
    }
    
    func tournamentInvalidAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let nameInvalidAlert = UIAlertController(title: "Oops!", message: "Please enter a tournament.", preferredStyle: UIAlertController.Style.alert)
            
            nameInvalidAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                
                // self.tournamentNameTextField.text = nil
            }))
            
            self.present(nameInvalidAlert, animated: true, completion: nil)
        }
    }
    
    
    func noTournamentRecordAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let endMatchAlert = UIAlertController(title: "Oops!", message: "There is no record of that tournament.", preferredStyle: UIAlertController.Style.alert)
            
            endMatchAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                
                self.tournamentNameTextField.text = nil
            }))
            
            self.present(endMatchAlert, animated: true, completion: nil)
        }
        
    }
    
    func handleNoPlayer(userName: String) {
        
        DispatchQueue.main.async {
            self.stopActivity()
            
            let defaults = UserDefaults.standard
            
            let endMatchAlert = UIAlertController(title: "Oops!", message: userName + " is not a player in this tournament. Would you like to be a spectator?", preferredStyle: UIAlertController.Style.alert)
            
            endMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                if let tournamentNameString = self.tournamentNameTextField.text {
                    print("Wants to be a spectator")
                    self.user.setUser(name: self.userName, role: "Spectator", scorekeeper: false, isInMatch: false)
                    defaults.set("Spectator", forKey: "UserRole")
                    defaults.set(false, forKey: "Scorekeeper")
                    defaults.set(tournamentNameString, forKey: "TournamentName")
                    self.delegate?.loggedIn(tournamentName: tournamentNameString)
                }
                else {
                    self.viewDidLoad()
                }
            }))
            endMatchAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Doesn't want to be a spectator")
                self.viewDidLoad()
            }))
            
            self.present(endMatchAlert, animated: true, completion: nil)
        }
    }
    
    func iCloudLoginAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: "Please try logging into iCloud to proceed. Go to Settings -> iCloud.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func upgradeiOSAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: "Please upgrade your OS to 10.0 or  above.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func noUserError() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: "We could not find your iCloud user name. Check that iCloud is turned on in your settings.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func noUserIDError() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: "We could not find your User ID.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func catchAllError(_ error: String) {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: "An error occurred: " + error, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func errorAlert(_ error: Error?) {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Oops!", message: error.debugDescription, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func incorrectPasswordAlert() {
        DispatchQueue.main.async {
            self.stopActivity()
            
            let alert = UIAlertController(title: "Sorry", message: "That password is incorrect.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.viewDidLoad()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()  //if desired
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        if self.activeTextField == tournamentNameTextField {
            pickerView.isHidden = false
            return false
        }
        else {
            pickerView.isHidden = true
        }
        
        return true
    }
    
    private func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        if self.activeTextField == tournamentNameTextField {
            pickerView.isHidden = false
            return false
        }
        else {
            pickerView.isHidden = true
        }
        
        return true
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

