//
//  SignUpViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/13/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    
    var db : Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        // Do any additional setup after loading the view.
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if isValidEmail(testStr: email.text!) {
//            if email.text?.components(separatedBy: "@")[1] != currentSchool.email {
//                let msg = "Please use an email account provided to you by your school. The email address for " + currentSchool.name + " is:\n {username}@" + currentSchool.email
//                let alertController = UIAlertController(title: "Invalid Email!", message: msg, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
//            }
            if password.text != passwordConfirm.text {
                let alertController = UIAlertController(title: "Passwords do not Match!", message: "Please re-type password. Passwords are case sensitive.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let username = email.text?.components(separatedBy: "@")[0]
                var errorUp : Error?
                Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (userr, error1) in
                    if error1 == nil {
                        let user = Auth.auth().currentUser
                        if let user = user{
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = currentSchool.name + "-" + username!
                            changeRequest.commitChanges(completion: { (error2) in
                                if error2 != nil {
                                    errorUp = error2
                                }
                            })
                        }
                        if errorUp == nil {
                            self.db.collection("Users").document(self.email.text!).setData([
                                "isAdmin" : false,
                                "isOffCampus" : false,
                                "isCampusLock" : false,
                                "lastDayOff" : "01-01-00",
                                "campusLockExpiry" : "01-01-00",
                                "numTimesOff" : 0,
                                "school" : currentSchool.name,
                                "timesAllowedOff" : currentSchool.numTimes
                                ])
                            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                                if error != nil {
                                    self.handleError(error!)
                                }
                                else {
                                    let alertController = UIAlertController(title: "Verification", message: "A verification email was sent to your mailbox, please follow the instructions int the email, then login.", preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: { () in
                                        self.performSegue(withIdentifier: "signupToLogin", sender: self)
                                    })
                                }
                            })
                        }
                        
                    }
                    else{
                        if error1 != nil {
                            print(error1!._code)
                            self.handleError(error1!)      // use the handleError method
                            return
                        }
                        else {
                            print(errorUp!._code)
                            self.handleError(errorUp!)
                            return
                        }
                    }
                }
            }
        }
        else{
            let msg = "Please enter a valid email address."
            let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        email.resignFirstResponder()
        password.resignFirstResponder()
        passwordConfirm.resignFirstResponder()
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
