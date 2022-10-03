//
//  ViewController.swift
//  Restore Master Pro
//
//  Created by Online on 22/09/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
 
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
      super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.isHidden = true
        self.passwordTextField.isSecureTextEntry = true
    }

    func smoothTab() -> [TabItem] {
      let v1 = restoreStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
      let v2 = restoreStoryboard.instantiateViewController(withIdentifier: "UploadedImagesViewController") as! UploadedImagesViewController
        
      let v3 = restoreStoryboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
        
      let v4 = restoreStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
      let t1 = TabItem(v1, imageName: "home", tabName: "Home")
      let t2 = TabItem(v2, imageName: "gallery", tabName: "Gallery")
      let t3 = TabItem(v3, imageName: "video", tabName: "Video")
      let t4 = TabItem(v4, imageName: "profile", tabName: "Profile")
      
      return [t1,t2,t3,t4]
    }
    
    func handleUserSignIn(isUserLogin: Bool){
        if (isUserLogin){
            UserDefaults.standard.set(userNameTextField.text, forKey: "UserName")
            UserDefaults.standard.set(true, forKey: "FirstTimeUserLogin")
            UserDefaults.standard.synchronize()
           
            print("You Are Successfully login")
            let dashboard = AppTabBarViewController.init(nibName: "AppTabBarViewController", bundle: nil,smoothData: smoothTab())
            let navigation = UINavigationController.init(rootViewController: dashboard)
            UIApplication.shared.windows.first?.rootViewController = navigation
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            emailTextField.text?.removeAll()
            passwordTextField.text?.removeAll()
        }else{
            emailTextField.text?.removeAll()
            passwordTextField.text?.removeAll()
        }
    }
    
    @IBAction func logInAction(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        let isValidateEmail = Validation.validation.validateEmailId(emailID: email)
        let isValidatePassword = Validation.validation.validatePassword(password: password)
        
        if (isValidateEmail == false) {
            self.alert(message: "Enter Correct Email", title: "Email Alert")
        } else if (isValidatePassword == false){
            self.alert(message: "Enter Correct Password", title: "Password Alert")
        }else if(isValidateEmail == true && isValidatePassword == true){
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                var isUserLogin = true
                let userUuid = Auth.auth().currentUser?.uid
                UserDefaults.standard.set(email, forKey: "emailID")
                UserDefaults.standard.synchronize()
                UserDefaults.standard.set(userUuid, forKey: "UserUUid")
                UserDefaults.standard.synchronize()
                if let error = error {
                    print("Unable to sign user in with error:\(error.localizedDescription)")
                    isUserLogin = false
                }
                DispatchQueue.main.async {
                    self.handleUserSignIn(isUserLogin: isUserLogin)
                }
            })
        }
    }
    
    
    @IBAction func dontHaveAnAccount(_ sender: Any) {
        let vc  = restoreStoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let vc = restoreStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  }

