//
//  AdminTableViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/20/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class AdminTableViewController: UITableViewController, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    
    var searchActive : Bool = false
    var data : Array<String> = Array()
    var filtered : Array<String> = Array()
    var db : Firestore!
    var email = "nil"
    var onlyUsersOff = false
    var indexAt = 0
    var currentUsersOff = Array<String>()
    var selectedUser = "nil"
    
    var resultSearchController = UISearchController()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(_:)))
        tableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = UIBarStyle.default
            controller.searchBar.barTintColor = UIColor.darkGray
            controller.searchBar.backgroundColor = UIColor.darkGray
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        
        if onlyUsersOff {
            updateCurrentUsersOff()
            data = currentUsersOff.sorted()
            self.tableView.reloadData()
        }
        else {
            db.collection("Users").getDocuments { (query, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                }
                else {
                    for doc in query!.documents {
                        if doc.documentID.components(separatedBy: "@")[1] == currentSchool.email{
                            self.data.append(doc.documentID)
                        }
                    }
                    self.data = self.data.sorted()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
   override func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.isActive {
            return self.filtered.count
        }else{
            return self.data.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        if self.resultSearchController.isActive {
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = data[indexPath.row]
        }
        return cell
    }
    
    @objc func tapEdit(_ recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) {
                    print(tappedCell.textLabel!.text!)
                    tappedCell.setSelected(true, animated: true)
                    selectedUser = tappedCell.textLabel!.text!
                    tappedCell.setSelected(false, animated: true)
                    self.performSegue(withIdentifier: "tableToUser", sender: self)
                }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filtered.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text ?? "")
        let array = (data as NSArray).filtered(using: searchPredicate)
        filtered = array as! [String]
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexAt = indexPath.row
    }
    
    func updateCurrentUsersOff(){
        db.collection("Schools").document("schools").getDocument { (document, error) in
            if let document = document, document.exists {
                let schools = document.data()! as NSDictionary
                let values = schools[currentSchool.name] as! NSDictionary
                self.currentUsersOff = values["currentUsersOff"] as! Array
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToUser" {
            let vc = segue.destination as! UserViewController
            vc.email = selectedUser
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
