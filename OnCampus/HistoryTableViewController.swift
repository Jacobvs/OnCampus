//
//  HistoryTableViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/25/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit
import Firebase

class HistoryTableViewController: UITableViewController, UISearchResultsUpdating, UIGestureRecognizerDelegate {

    var searchActive : Bool = false
    var data : Array<String> = Array()
    var filtered : Array<String> = Array()
    var db : Firestore!
    var email = "nil"
    var indexAt = 0
    var currentRow = -1
    var isSmall = false
    var expandedIndexes = Array<Int>()
    
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
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        //add data
        db.collection("Users").document(email).collection("history").getDocuments { (query, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for doc in query!.documents {
                        print(doc.documentID)
                        self.data.append(doc.documentID)
                    }
                }
            self.data = self.data.sorted()
            self.tableView.reloadData()
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HistoryTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        cell.setupCell()
        
        let numberFormatter:NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.ordinal
        
        //fix these names
        if self.resultSearchController.isActive {
            cell.title!.text = filtered[indexPath.row].components(separatedBy: ":")[0]
            cell.timeOut!.text = numberFormatter.string(from: NSNumber.init(integerLiteral: Int(filtered[indexPath.row].components(separatedBy: ":")[1])! + 1))! + " time off campus."
            db.collection("Users").document(email).collection("history").document(filtered[indexPath.row]).getDocument { (document, error) in
                if let document = document, document.exists {
                let values = document.data() ?? ["nil" : "nil"]
                    cell.destination!.text = "Destination: " + (values["destination"] as! String)
                    cell.transportMethod!.text = "Transport Method: " + (values["transportMethod"] as! String)
                    cell.expectedReturn!.text = "Expected Return: " + (values["expectedReturn"] as! String)
                    cell.signOut!.text = "Signed out at: " + (values["signOut"] as! String)
                    cell.signIn!.text = "Signed in at: " + (values["signIn"] as? String ?? "Has not signed back in.")
                }
            }
        } else {
            cell.title!.text = data[indexPath.row].components(separatedBy: ":")[0]
            cell.timeOut!.text = numberFormatter.string(from: NSNumber.init(integerLiteral: Int(data[indexPath.row].components(separatedBy: ":")[1])! + 1))! + " time off campus."
            db.collection("Users").document(email).collection("history").document(data[indexPath.row]).getDocument { (document, error) in
                if let document = document, document.exists {
                    let values = document.data() ?? ["nil" : "nil"]
                    cell.destination!.text = "Destination: " + (values["destination"] as! String)
                    cell.transportMethod!.text = "Transport Method: " + (values["transportMethod"] as! String)
                    cell.expectedReturn!.text = "Expected Return: " + (values["expectedReturn"] as! String)
                    cell.signOut!.text = "Signed out at: " + (values["signOut"] as! String)
                    cell.signIn!.text = "Signed in at: " + (values["signIn"] as? String ?? "Has not signed back in.")
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedIndexes.contains(indexPath.row) {
            return 140
        }
        else {
            return 41.0
        }
    }
    
    @objc func tapEdit(_ recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as! HistoryTableViewCell
                //currentRow = tapIndexPath.row
                if expandedIndexes.contains(tapIndexPath.row) {
                    expandedIndexes.remove(at: expandedIndexes.index(of: tapIndexPath.row)!)
                }
                else {
                    expandedIndexes.append(tapIndexPath.row)
                }
                isSmall = tappedCell.isSmall
                tappedCell.isSmall.toggle()
                tappedCell.setSelected(true, animated: true)
                tappedCell.setSelected(false, animated: true)
                if isSmall {
                    UIView.animate(withDuration: 0.5) {
                        tappedCell.caret.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    }
                }
                else {
                    UIView.animate(withDuration: 0.5) {
                        tappedCell.caret.transform = CGAffineTransform.init(rotationAngle: 0)
                    }
                }
                tableView.beginUpdates()
                tableView.endUpdates()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


