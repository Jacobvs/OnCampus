//
//  LoginViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/13/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var isAdmin = false
    var db : Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        
        if currentSchool.authType == "native" {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
                if error == nil{
                    if (Auth.auth().currentUser?.isEmailVerified)! {
                        self.db.collection("Users").document(self.email.text!).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let values = document.data() ?? ["nil" : "nil"]
                                self.isAdmin = values["isAdmin"] as! Bool
                            }
                            if self.isAdmin {
                                self.performSegue(withIdentifier: "loginToAdmin", sender: self)
                            }
                            else {
                                self.performSegue(withIdentifier: "loginToHome", sender: self)
                            }
                        }
                    }
                    else {
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        })
                        let alertController = UIAlertController(title: "Verification", message: "Please complete email verification before logging in!", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: { () in
                            do {
                                try Auth.auth().signOut()
                            }
                            catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                        })
                    }
                }
                else{
                    print(error!._code)
                    self.handleError(error!)      // use the handleError method
                    return
                }
            }
        }
        else if currentSchool.authType == "AzureAD" {
            
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account."
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again or signup on the previous page."
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password."
        default:
            return "Unknown error occurred"
        }
    }
}


extension UIViewController{
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
