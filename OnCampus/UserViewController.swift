//
//  UserViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/24/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var signedOutYesIcon: UIImageView!
    @IBOutlet weak var signedOutNoIcon: UIImageView!
    @IBOutlet weak var campusLockYesIcon: UIImageView!
    @IBOutlet weak var campusLockNoIcon: UIImageView!
    @IBOutlet weak var campusLockDetailLabel: UILabel!
    @IBOutlet weak var timesAllowedOffPerDayLabel: UILabel!
    @IBOutlet weak var addCampusLockButton: UIButton!
    @IBOutlet weak var removeCampusLockButton: UIButton!
    @IBOutlet weak var resetDailySignoutsButton: UIButton!
    @IBOutlet weak var refreshIcon: UIImageView!
    @IBOutlet weak var textBS: UITextField!
    
    var isCampusLock : Bool = false
    var isOffCampus : Bool = false
    var campusLockExpiry : String = "01-01-00"
    var lastDayOff : String = "01-01-00"
    var numTimesOff : Int = 0
    var timesAllowedOff : Int = 1
    var username = "nil"
    var email = "nil"
    var db : Firestore!
    
    var newCampusLockDate = ""
    
    var datePicker = UIDatePicker()
    var toolbar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        username = email.components(separatedBy: "@")[0]
        
        navigationController?.navigationItem.title = username
        usernameLabel.text = username
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        refreshIcon.isUserInteractionEnabled = true
        refreshIcon.addGestureRecognizer(tapGestureRecognizer)
        
        campusLockYesIcon.isHidden = true
        campusLockNoIcon.isHidden = true
        signedOutYesIcon.isHidden = true
        signedOutNoIcon.isHidden = true
        campusLockDetailLabel.isHidden = true
        campusLockDetailLabel.adjustsFontSizeToFitWidth = true
        textBS.isUserInteractionEnabled = true
        textBS.frame = CGRect.zero
        
        
        getUserStatus()
        createDatePicker()
        createToolBar()
        
        textBS.inputView = datePicker
        textBS.inputAccessoryView = toolbar

        // Do any additional setup after loading the view.
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    
    func createToolBar() {
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addButtonPressed(sender:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([cancelButton, flexibleSpace,addButton], animated: true)
    }
    
    @objc func addButtonPressed(sender: UIBarButtonItem) {
        print("heyy")
        if datePicker.date.compare(Date()) == ComparisonResult.orderedDescending {
            let alert = UIAlertController(title: "Add Campus Lock", message: "Would you like to add a new campus lock for " + String(username) +
                " that expires on: " + formatDate(datePicker.date) + "?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            let okAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                self.db.collection("Users").document(self.email).updateData(["isCampusLock" : true, "campusLockExpiry" : self.formatDate(self.datePicker.date)])
                self.getUserStatus()
                print("YUHH")
                self.textBS.resignFirstResponder()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please ensure the time is set to the future.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.textBS.resignFirstResponder()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func cancelButtonPressed(sender: UIBarButtonItem) {
        textBS.resignFirstResponder()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textBS.resignFirstResponder()
        view.endEditing(true)
    }
    
    func getUserStatus(){
        print(email)
        db.collection("Users").document(email).getDocument { (document, error) in
            if let document = document, document.exists {
                print("yeyy inside")
                let values = document.data() ?? ["nil" : "nil"]
                self.isOffCampus = values["isOffCampus"] as! Bool
                self.isCampusLock = values["isCampusLock"] as! Bool
                self.campusLockExpiry = values["campusLockExpiry"] as! String
                self.lastDayOff = values["lastDayOff"] as! String
                self.numTimesOff = values["numTimesOff"] as! Int
                self.timesAllowedOff = values["timesAllowedOff"] as! Int
            }
            self.updateUserValues()
        }
    }
    
    func updateUserValues(){
        if isCampusLock{
            campusLockYesIcon.isHidden = false
            campusLockNoIcon.isHidden = true
            campusLockDetailLabel.text = "Campus Locked Until: " + campusLockExpiry
            campusLockDetailLabel.isHidden = false
        }
        else {
            campusLockNoIcon.isHidden = false
            campusLockYesIcon.isHidden = true
            campusLockDetailLabel.isHidden = true
        }
        if isOffCampus{
            signedOutYesIcon.isHidden = false
            signedOutNoIcon.isHidden = true
        }
        else {
            signedOutNoIcon.isHidden = false
            signedOutYesIcon.isHidden = true
        }
    }
    
    @IBAction func addCampusLock(_ sender: Any) {
        textBS.becomeFirstResponder()
    }
    
    @IBAction func removeCampusLock(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Campus Lock", message: "Are you sure you would like to remove the campus lock for " + username + "?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            self.db.collection("Users").document(self.email).updateData(["isCampusLock" : false])
            self.getUserStatus()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetDailySignouts(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Signouts", message: "Are you sure you would like to reset today's signouts for " + username + "?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            self.db.collection("Users").document(self.email).updateData(["numTimesOff" : 0])
            self.getUserStatus()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func viewHistory(_ sender: Any) {
        self.performSegue(withIdentifier: "userToHistory", sender: self)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        UIImageView.animate(withDuration: 0.5) { () -> Void in
            self.refreshIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.45, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            self.refreshIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
        
        getUserStatus()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userToHistory" {
            let vc = segue.destination as! HistoryTableViewController
            vc.email = self.email
        }
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
