//
//  ForgotPasswordViewController.swift
//  Restore Master Pro
//
//  Created by Online on 26/09/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        hideKeyboardWhenTappedAround()
       
    }
   

    @IBAction func sendLink(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            var title = ""
            var message = ""
            
            if error != nil {
                title = "Error!"
                message = (error?.localizedDescription)!
            } else {
                title = "Success!"
                message = "Password reset email sent."
                self.emailTextField.text = ""
                
                self.alert(message: message, title: title)
            }
        })
        emailTextField.text?.removeAll()
    }
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
