//
//  HomeViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/13/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var currUserLabel: UILabel!
    @IBOutlet weak var powerButtonNo: UIImageView!
    @IBOutlet weak var powerButtonOn: UIImageView!
    @IBOutlet weak var powerButtonOff: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var campusLockLabel: UILabel!
    @IBOutlet weak var lastDayOffLabel: UILabel!
    
    
    var isCampusLock : Bool = false
    var isOffCampus : Bool = false
    var isAdmin : Bool = false
    var campusLockExpiry : String = "01-01-00"
    var lastDayOff : String = "01-01-00"
    var numTimesOff : Int = 0
    var timesAllowedOff : Int = 1
    var user : NSDictionary = ["nil": "nil"]
    var name = "nil"
    var username = "nil"
    var email = "nil"
    var db : Firestore!
    var campusLockText : String = "Not Campus Locked"


    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
        
        powerButtonNo.isHidden = true
        powerButtonOn.isHidden = true
        powerButtonOff.isHidden = true
        campusLockLabel.isHidden = true
        lastDayOffLabel.isHidden = true
        powerButtonNo.isUserInteractionEnabled = false
        powerButtonOn.isUserInteractionEnabled = false
        powerButtonOff.isUserInteractionEnabled = false
        
        setupNoButton()
        setupOnButton()
        setupOffButton()
        
        getUserStatus()
        checkLimits()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        db = Firestore.firestore()
        
        
        let tapNo = UITapGestureRecognizer(target: self, action: #selector(buttPress(_:)))
        let tapOn = UITapGestureRecognizer(target: self, action: #selector(buttPress(_:)))
        let tapOff = UITapGestureRecognizer(target: self, action: #selector(buttPress(_:)))

        powerButtonNo.addGestureRecognizer(tapNo)
        powerButtonOn.addGestureRecognizer(tapOn)
        powerButtonOff.addGestureRecognizer(tapOff)
        
        
        username = Auth.auth().currentUser!.email ?? "nil"
        name = username.components(separatedBy: "@")[0]
        email = username.components(separatedBy: "@")[1]
        
        currUserLabel.text = "Logged in as: " + name
        currUserLabel.adjustsFontSizeToFitWidth = true
        campusLockLabel.adjustsFontSizeToFitWidth = true
        lastDayOffLabel.adjustsFontSizeToFitWidth = true
        self.lastDayOffLabel.text = "You have already left campus once today, please try again tomorrow.\nContact a School Admin if you think this is a mistake."

    }
    override func viewWillDisappear(_ animated: Bool) {
        showNavigationBar()
    }
    
    func setupNoButton(){
        powerButtonNo.animationImages = [#imageLiteral(resourceName: "no1"),#imageLiteral(resourceName: "no2"),#imageLiteral(resourceName: "no3"),#imageLiteral(resourceName: "no4"),#imageLiteral(resourceName: "no5"),#imageLiteral(resourceName: "no6")]
        powerButtonNo.animationDuration = 0.25
    }
    func setupOnButton(){
        powerButtonOn.animationImages = [#imageLiteral(resourceName: "on1"),#imageLiteral(resourceName: "on2"),#imageLiteral(resourceName: "on3"),#imageLiteral(resourceName: "on4"),#imageLiteral(resourceName: "on5"),#imageLiteral(resourceName: "on6")]
        powerButtonOn.animationDuration = 0.25
    }
    func setupOffButton(){
        powerButtonOff.animationImages = [#imageLiteral(resourceName: "off1"),#imageLiteral(resourceName: "off2"),#imageLiteral(resourceName: "off3"),#imageLiteral(resourceName: "off4"),#imageLiteral(resourceName: "off5"),#imageLiteral(resourceName: "off6")]
        powerButtonOff.animationDuration = 0.25
    }
    func animateButton(){
        powerButtonNo.isUserInteractionEnabled = false
        powerButtonOff.isUserInteractionEnabled = false
        powerButtonOn.isUserInteractionEnabled = false
        if isCampusLock || numTimesOff >= timesAllowedOff {
            powerButtonNo.startAnimating()
        }
        else if isOffCampus {
            powerButtonOff.startAnimating()
        }
        else {
            powerButtonOn.startAnimating()
        }
    }
    func stopAnimating(){
        if isCampusLock || numTimesOff >= timesAllowedOff {
            self.powerButtonNo.stopAnimating()
        }
        else if isOffCampus {
            self.powerButtonOff.stopAnimating()
        }
        else {
            self.powerButtonOn.stopAnimating()
        }
    }
    
    @objc func buttPress(_ sender: UITapGestureRecognizer) {
        if !checkLimits() {
            self.animateButton()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.switchUserStatus()
                self.stopAnimating()
            }
        }
    }
    
    func buttonStatus(){
        if isCampusLock {
            statusLabel.text = "Campus Locked"
            powerButtonNo.isHidden = false
            powerButtonOn.isHidden = true
            powerButtonOff.isHidden = true
            campusLockLabel.isHidden = false
            lastDayOffLabel.isHidden = true
            powerButtonNo.isUserInteractionEnabled = true
            powerButtonOn.isUserInteractionEnabled = false
            powerButtonOff.isUserInteractionEnabled = false
        }
        else if numTimesOff >= timesAllowedOff && !isOffCampus {
            statusLabel.text = "Campus Locked"
            powerButtonNo.isHidden = false
            powerButtonOn.isHidden = true
            powerButtonOff.isHidden = true
            campusLockLabel.isHidden = true
            lastDayOffLabel.isHidden = false
            powerButtonNo.isUserInteractionEnabled = true
            powerButtonOn.isUserInteractionEnabled = false
            powerButtonOff.isUserInteractionEnabled = false
        }
        else if isOffCampus {
            statusLabel.text = "Off Campus"
            powerButtonNo.isHidden = true
            powerButtonOn.isHidden = true
            powerButtonOff.isHidden = false
            campusLockLabel.isHidden = true
            lastDayOffLabel.isHidden = true
            powerButtonNo.isUserInteractionEnabled = false
            powerButtonOn.isUserInteractionEnabled = false
            powerButtonOff.isUserInteractionEnabled = true
        }
        else {
            statusLabel.text = "On Campus"
            powerButtonNo.isHidden = true
            powerButtonOn.isHidden = false
            powerButtonOff.isHidden = true
            campusLockLabel.isHidden = true
            lastDayOffLabel.isHidden = true
            powerButtonNo.isUserInteractionEnabled = false
            powerButtonOn.isUserInteractionEnabled = true
            powerButtonOff.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func logOutAction(_ sender: UITapGestureRecognizer) {
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
    
    func getUserStatus(){
        print("heyy")
        db.collection("Users").document(username).getDocument { (document, error) in
            if let document = document, document.exists {
                let values = document.data() ?? ["nil" : "nil"]
                self.isAdmin = values["isAdmin"] as! Bool
                self.isOffCampus = values["isOffCampus"] as! Bool
                self.isCampusLock = values["isCampusLock"] as! Bool
                self.campusLockExpiry = values["campusLockExpiry"] as! String
                self.lastDayOff = values["lastDayOff"] as! String
                self.numTimesOff = values["numTimesOff"] as! Int
                self.timesAllowedOff = values["timesAllowedOff"] as! Int
                self.campusLockLabel.text = "You are not allowed to leave campus until:\n" + self.campusLockExpiry + "\nPlease Contact a School Admin if you think this is a mistake."
                self.buttonStatus()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offCampusView" {
            let vc = segue.destination as! OffCampusViewController
            vc.username = self.username
            vc.numTimesOff = self.numTimesOff
            vc.isOffCampus = self.isOffCampus
        }
        else if segue.identifier == "adminView" {
            let vc = segue.destination as! AdminTableViewController
            vc.email = self.email
        }
    }
    
    func switchUserStatus(){
        if isOffCampus {
            numTimesOff -= 1
            let userRef = db.collection("Users").document(username)
            userRef.updateData(["isOffCampus": false])
            userRef.collection("history").document(formatDate(Date()) + ":" + String(numTimesOff)).setData(["signIn" : formatTime(Date())], merge: true)
            db.collection("Schools").document("schools").setData([currentSchool.name : ["currentUsersOff" : FieldValue.arrayRemove([username])]], merge: true)
            self.isOffCampus.toggle()
            buttonStatus()
            numTimesOff += 1
        }
        else{
            if !self.isCampusLock && self.numTimesOff < self.timesAllowedOff {
                performSegue(withIdentifier: "offCampusView", sender: self)
            }
            else {
                buttonStatus()
            }
        }
    }
    
    func checkLimits() -> Bool {
        var change = 0
        if numTimesOff >= timesAllowedOff {
            print("one: " + String(formatDateToDate(lastDayOff) < formatDateToDate(formatDate(Date()))))
            print(formatDateToDate(lastDayOff))
            print(formatDateToDate(formatDate(Date())))
            if formatDateToDate(lastDayOff) < formatDateToDate(formatDate(Date())) {
                db.collection("Users").document(username).updateData(["numTimesOff" : 0])
                numTimesOff = 0
                buttonStatus()
                change += 1
            }
        }
        else if isCampusLock {
            print("two: " + String(formatDateToDate(campusLockExpiry) < Date()))
            if formatDateToDate(campusLockExpiry) < Date() {
                db.collection("Users").document(username).updateData(["isCampusLock" : false])
                isCampusLock = false
                buttonStatus()
                change += 1
            }
        }
        return change > 0
    }

}
