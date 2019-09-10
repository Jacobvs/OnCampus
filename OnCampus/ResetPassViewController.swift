//
//  ResetPassViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/14/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class ResetPassViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func reset(_ sender: Any) {
        let lvc = storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        if email.text != nil {
            Auth.auth().sendPasswordReset(withEmail: email.text!) { error in
                if error == nil {
                    let alert = UIAlertController(title: "Password Reset", message: "Please check your inbox for a link to reset your password.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    self.present(lvc, animated: true, completion: nil)
                }
                else{
                    print(error!._code)
                    self.handleError(error!)
                    return
                }
                
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please enter an email.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        email.resignFirstResponder()
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
