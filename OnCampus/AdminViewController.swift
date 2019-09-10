//
//  AdminViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/20/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class AdminViewController: UIViewController {
    
    var db : Firestore!
    var email = "nil"
    var currentUsersOff = Array<String>()
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        db.collection("Schools").document("schools").getDocument { (document, error) in
            if let document = document, document.exists {
                let schools = document.data()! as NSDictionary
                let values = schools[currentSchool.name] as! NSDictionary
                self.currentUsersOff = values["currentUsersOff"] as! Array
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        showNavigationBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "currentUsersOff" {
            let vc = segue.destination as! AdminTableViewController
            vc.email = currentSchool.email
            vc.onlyUsersOff = true
            vc.currentUsersOff = self.currentUsersOff
        }
        else if segue.identifier == "allUsers" {
            let vc = segue.destination as! AdminTableViewController
            vc.email = currentSchool.email
            vc.onlyUsersOff = false
            vc.currentUsersOff = self.currentUsersOff
        }
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "schoolViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
//
//
//
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
