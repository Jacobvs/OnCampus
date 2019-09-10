//
//  SchoolViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/12/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class SchoolViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var schoolDetail: UILabel!
    
    var pickerData: Array<String> = Array()
    var db : Firestore!
    var chosen:String? = nil
    var isAdmin = false

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar()
        db = Firestore.firestore()
        pickerTextField.adjustsFontSizeToFitWidth = true
        
        if Auth.auth().currentUser != nil {
            isSignedIn()
        }
        
        let schoolPicker = UIPickerView()
        schoolPicker.delegate = self
        //pickerData.append("Choose A School.")
        
        let schoolRef = db.collection("Schools").document("schools")
        schoolRef.getDocument { (document, error) in
            if let document = document, document.exists {
                currentSchool.school = document.data() ?? ["nil" : "nil"]
                for val in currentSchool.school.keys{
                    if !self.pickerData.contains(val) {
                        self.pickerData.append(val)
                    }
                }
            } else {
                print("Document does not exist")
            }
            if self.pickerData.count > 1 {
                self.pickerTextField.inputView = schoolPicker
                self.doneButton.isHidden = false
                self.doneButton.isUserInteractionEnabled = true
                self.schoolDetail.isHidden = false
            }
            else if self.pickerData.count == 1 {
                currentSchool.name = self.pickerData[0]
                if let schools = currentSchool.school[self.pickerData[0]] as? [String:Any]{
                    currentSchool.email = schools["email"] as! String
                    currentSchool.numTimes = schools["timesAllowedOff"] as! Int
                    currentSchool.authType = schools["authType"] as! String
                }
                self.pickerTextField.text = self.pickerData[0]
                self.chosen = self.pickerData[0]
                self.schoolDetail.isHidden = true
                self.doneButton.isHidden = false
                self.doneButton.isUserInteractionEnabled = true
            }
            else {
                self.pickerTextField.text = "No Schools Found."
                self.doneButton.isHidden = true
                self.doneButton.isUserInteractionEnabled = false
                self.schoolDetail.isHidden = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerData = pickerData.sorted()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pickerTextField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    //MARK:- UIPickerViewDelegates methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
//        var selectedRow = row
//        if selectedRow == 0 {
//            selectedRow = 1
//            pickerView.selectRow(selectedRow, inComponent: component, animated: false)
//        }
        
        currentSchool.name = pickerData[row]
        if let schools = currentSchool.school[pickerData[row]] as? [String:Any]{
            currentSchool.email = schools["email"] as! String
            currentSchool.numTimes = schools["timesAllowedOff"] as! Int
            currentSchool.authType = schools["authType"] as! String
        }
        pickerTextField.text = pickerData[row]
        chosen = pickerData[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "schoolToSelect" {
            if chosen != nil && chosen != "Please select a school." && chosen != "Select a School" {
                return true
            }
            else {
                let alertCont = UIAlertController(title: "Error", message: "Please choose a school.\nIf no schools appear, please check your internet connection or contact our support.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertCont.addAction(okAction)
                present(alertCont, animated: true, completion: nil)
                return false
            }
        }
        return false
    }
    
    func isSignedIn(){
        if currentSchool.name == "nil" || currentSchool.email == "nil" {
            if Auth.auth().currentUser?.displayName != nil {
                currentSchool.name = (Auth.auth().currentUser?.displayName?.components(separatedBy: "-")[0])!
                db.collection("Schools").document("schools").getDocument { (document, error) in
                    if let document = document, document.exists {
                        let schools = document.data()! as NSDictionary
                        let values = schools[currentSchool.name] as! NSDictionary
                        currentSchool.email = values["email"] as! String
                        cuurrentSchool.numTimes = values["timesAllowedOff"] as! Int
                        currentSchool.authType = values["authType"] as! String
                    }
                }
            }
            else {
                do {
                    try Auth.auth().signOut()
                }
                catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            }
        }
        db.collection("Users").document((Auth.auth().currentUser?.email)!).getDocument { (document, error) in
            if let document = document, document.exists {
                let values = document.data() ?? ["nil" : "nil"]
                self.isAdmin = values["isAdmin"] as! Bool
            }
            if self.isAdmin {
                self.performSegue(withIdentifier: "schoolToAdmin", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "schoolToHome", sender: self)
            }
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

extension UIViewController {
    func hideNavigationBar(){
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.hidesBarsOnSwipe = false
        
    }
    
    func showNavigationBar() {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
}

struct currentSchool {
    static var name = "nil"
    static var email = "nil"
    static var authType = "nil"
    static var numTimes = 1
    static var school = [String : Any]()
}
