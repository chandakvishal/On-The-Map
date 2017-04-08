//
//  LoginViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 18/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // MARK: Properties

    var keyboardOnScreen = false

    // MARK: Outlets

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel:    UILabel!
    @IBOutlet weak var loginButton:       UIButton!
    @IBOutlet weak var signUpButton:      UIButton!

    let LookDisabled = 0.5
    let LookEnabled  = 1.0

    var session: URLSession!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }

    func tap(gesture: UITapGestureRecognizer) {
        userDidTapView(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugTextLabel.text = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    // MARK: Actions

    @IBAction func loginPressed(_ sender: AnyObject) {
        userDidTapView(self)
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)

            OnTheMapClient.sharedInstance().loginHandler(self,
                                                         username: usernameTextField.text!,
                                                         password: passwordTextField.text!) {
                (success, errorString) in
                OnTheMapClient.sharedInstance().performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                        self.setUIEnabled(true)
                    } else {
                        self.setUIEnabled(true)
                        self.displayError(errorString)
                    }
                }
            }

        }
    }

    // MARK: Change View to Maps

    private func completeLogin() {
        debugTextLabel.text = ""
        print("Login Completed successfully!")
        let controller
                = storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }

    @IBAction func signUpPressed(_ sender: AnyObject) {
        if let signUpURL = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated") {
            UIApplication.shared.open(signUpURL)
        }
    }

// MARK: Login

    private func backToLogin() {
        debugTextLabel.text = ""
        let controller
                = storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }

}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {

    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled

        // adjust login button alpha
        if enabled {
            loginButton.alpha = CGFloat(LookEnabled)
        } else {
            loginButton.alpha = CGFloat(LookDisabled)
        }
    }

    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }

    func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop           = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom        = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}

extension LoginViewController: UITextFieldDelegate {

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }

    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {

    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
