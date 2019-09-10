//
//  OffCampusViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/19/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class OffCampusViewController: UIViewController {
    
    var db : Firestore!
    @IBOutlet weak var transportMethod: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timeField: UITextField!
    
    var datePicker = UIDatePicker()
    var toolbar = UIToolbar()
    var username : String = "nil"
    var numTimesOff : Int = 0
    var isOffCampus : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        createDatePicker()
        createToolBar()
        timeField.inputView = datePicker
        timeField.inputAccessoryView = toolbar
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    
    func createToolBar() {
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        toolbar.setItems([flexibleSpace,doneButton], animated: true)
    }
    
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        timeField.resignFirstResponder()
    }
    
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        timeField.text = dateFormatter.string(from: datePicker.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func doneButtonClick(_ sender: Any) {
    
        if destination.text != nil && transportMethod.text != nil && datePicker.date.compare(Date()) == ComparisonResult.orderedDescending {
            db.collection("Users").document(username).collection("history").document(formatDate(Date()) + ":" + String(numTimesOff)).setData([
                "destination" : destination.text!,
                "transportMethod" : transportMethod.text!,
                "expectedReturn" : formatTime(datePicker.date),
                "signOut" : formatTime(Date())
                ])
            db.collection("Users").document(username).updateData(["isOffCampus" : true, "numTimesOff" : numTimesOff + 1, "lastDayOff" : formatDate(Date())])
            db.collection("Schools").document("schools").setData([currentSchool.name : ["currentUsersOff" : FieldValue.arrayUnion([username])]], merge: true)
            self.isOffCampus.toggle()
            //TODO -- add push notifications
            performSegue(withIdentifier: "infoToHome", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please ensure all fields are filled out and that the time is set to the future.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoToHome" {
            let vc = segue.destination as! HomeViewController
            vc.isOffCampus = self.isOffCampus
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
    func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none

        let formattedDateComp = df.string(from: date).components(separatedBy: "/")
        let formattedDate = formattedDateComp[0] + "-" + formattedDateComp[1] + "-" + formattedDateComp[2]
        return formattedDate
    }
    func formatTime(_ time: Date) -> String {
        let tf = DateFormatter()
        tf.dateStyle = .none
        tf.timeStyle = .short
        tf.timeZone = TimeZone(abbreviation: "PDT")
        return tf.string(from: time)
    }
    func formatDateToDate(_ date: String) -> Date {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df.date(from: date)!
    }
}
