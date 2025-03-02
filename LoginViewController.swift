import UIKit
import AuthenticationServices
import Security
import GoogleSignIn

protocol LoginViewControllerDelegate {
    func didCompleteLogin()
}

class LoginViewController: UIViewController {
    
    var delegate: LoginViewControllerDelegate?
    private let user = User.sharedInstance
    
    private var identifier: String?
    private var firstName: String?
    private var lastName: String?
    private var googleSignInButton: GIDSignInButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColorFromRGB(0x0F296B)

        setupAppleSignInButton()
        setupGoogleSignInButton()
        setupLogoAndTitle()
    }
    
    private func setupLogoAndTitle() {
        // Add your app logo/title here

    }
    
    private func setupAppleSignInButton() {
        let signInButton = ASAuthorizationAppleIDButton()
        signInButton.addTarget(self, action: #selector(handleAppleSignInButtonPress), for: .touchUpInside)
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 200),
            signInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupGoogleSignInButton() {
        googleSignInButton = GIDSignInButton()
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = .dark
        
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(googleSignInButton)
        
        NSLayoutConstraint.activate([
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            googleSignInButton.widthAnchor.constraint(equalToConstant: 200),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add target
        googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func handleAppleSignInButtonPress() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    @objc private func handleGoogleSignIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google sign in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let userId = user.userID,
                  let profile = user.profile else { return }
            
            // Save Google user ID to keychain
            self.saveToKeychain(userId: userId)
            
            // Get user details
            let fullName = [profile.givenName, profile.familyName].compactMap { $0 }.joined(separator: " ")
            self.firstName = profile.givenName
            self.lastName = profile.familyName
            self.identifier = userId
            
            // Upsert user to database
            Model.sharedInstance.upsertUser(
                identifier: userId,
                firstName: profile.givenName,
                lastName: profile.familyName,
                email: profile.email
            ) { success, error in
                if let error = error {
                    print("Failed to upsert user: \(error)")
                }
            }
            
            // Show name validation
            self.promptForNameValidation(defaultName: fullName)
            
            // Set email
            self.user.email = profile.email
        }
    }
    
    private let keychainService = "com.bluffcitycup.credentials"
    private let accountKey = "appleSignIn"

    private func saveToKeychain(userId: String) {
        let credentials = userId.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: credentials
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Error saving to Keychain: \(status)")
            return
        }
    }
    
    private func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                   didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Save user ID to keychain
                identifier = appleIDCredential.user
                saveToKeychain(userId: identifier!)
                
                #if targetEnvironment(simulator)
                // Use hardcoded values for simulator
                firstName = "Ross"
                lastName = "Montague"
                
                // Upsert user to database
                Model.sharedInstance.upsertUser(
                    identifier: identifier!,
                    firstName: firstName,
                    lastName: lastName,
                    email: "ross@montagues.us"
                ) { success, error in
                    if let error = error {
                        print("Failed to upsert user: \(error)")
                    }
                }
                
                promptForNameValidation(defaultName: "Ross Montague")
                #else
                // Get names from Apple credentials
                firstName = appleIDCredential.fullName?.givenName
                lastName = appleIDCredential.fullName?.familyName
                let fullName = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
                
                // Upsert user to database
                Model.sharedInstance.upsertUser(
                    identifier: identifier!,
                    firstName: firstName,
                    lastName: lastName,
                    email: appleIDCredential.email
                ) { success, error in
                    if let error = error {
                        print("Failed to upsert user: \(error)")
                    }
                }
                
                // Show name validation prompt
                promptForNameValidation(defaultName: fullName)
                #endif
            }
        }

    private func promptForNameValidation(defaultName: String) {
            let alert = UIAlertController(
                title: "Confirm Your Name",
                message: "Please confirm or edit your preferred name",
                preferredStyle: .alert
            )
            
            alert.addTextField { textField in
                textField.text = defaultName
                textField.placeholder = "Your name"
            }
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
                guard let self = self,
                      let nameField = alert.textFields?.first,
                      let name = nameField.text,
                      !name.isEmpty else { return }
                
                // Update user properties
                self.user.name = name
                self.user.firstName = self.firstName
                self.user.lastName = self.lastName
                self.user.identifier = self.identifier!
                
                // Save user name to UserDefaults
                // Save all user properties to UserDefaults
                let defaults = UserDefaults.standard
                defaults.set(name, forKey: "UserName")
                defaults.set(self.firstName, forKey: "UserFirstName")
                defaults.set(self.lastName, forKey: "UserLastName")
                defaults.set(self.identifier, forKey: "UserIdentifier")
                            
                
                // Set email if available
                #if targetEnvironment(simulator)
                self.user.email = "ross@montagues.us"
                #else
                if let email = appleIDCredential.email {
                    self.user.email = email
                }
                #endif
                
                // Notify delegate of successful login
                self.delegate?.didCompleteLogin()
            }
            
            alert.addAction(confirmAction)
            present(alert, animated: true)
        }

    func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithError error: Error) {
        // Handle error
        print("Sign in with Apple failed: \(error.localizedDescription)")
        
        let alert = UIAlertController(
            title: "Sign In Failed",
            message: "Please try again later.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
