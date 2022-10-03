//
//  RegisterViewController.swift
//  Restore Master Pro
//
//  Created by Online on 26/09/22.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        hideKeyboardWhenTappedAround()
        self.passwordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.isSecureTextEntry = true
    }
    
    func handleUserLogin(isSuccess: Bool) {
        if (isSuccess) {
            emailTextField.text?.removeAll()
            passwordTextField.text?.removeAll()
            confirmPasswordTextField.text?.removeAll()
            alert(message: "Sign Up Successfully", title: "Congratulation")
        } else {
            emailTextField.text?.removeAll()
            passwordTextField.text?.removeAll()
            confirmPasswordTextField.text?.removeAll()
        }
    }

    @IBAction func registerBtnAction(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let confirmPassword = confirmPasswordTextField.text else {return}
        
        let isValidateEmail = Validation.validation.validateEmailId(emailID: email)
        let isValidatePassword = Validation.validation.validatePassword(password: password)
        let isValidateConfirmPassword = Validation.validation.validatePassword(password: confirmPassword)
    
        if (isValidateEmail == false){
            self.alert(message: "Enter Corrent Email", title: "Email Error")
        }else if (isValidatePassword == false){
            self.alert(message: "Enter atleast one Uppercase, one Digit, one lowercase, one symbol and minimum 8 character", title: "Password Alert")
        }else if (isValidatePassword == false){
            self.alert(message: "Enter atleast one Uppercase, one Digit, one lowercase, one symbol and minimum 8 character", title: "Confir Password Alert")
        }else if (password != confirmPassword){
            self.alert(message: "Password Not Match", title: "Password Alert")
        }else if (isValidateEmail == true || isValidatePassword == true || isValidateConfirmPassword == true){
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                var isSuccess = true
                let userUuid = Auth.auth().currentUser?.uid
                UserDefaults.standard.set(userUuid, forKey: "UserUUid")
                UserDefaults.standard.synchronize()
                if let error = error {
                    print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
                    isSuccess = false
                }
                DispatchQueue.main.async {
                    self.handleUserLogin(isSuccess: isSuccess)
                }
            })
        }
    }
    
    @IBAction func youHaveAnAccount(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
