//
//  InternetViewController.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/19/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit

class InternetViewController: UIViewController {

    @IBOutlet weak var wifiIcon: UIImageView!
    @IBOutlet weak var wifiText: UILabel!
    
    let network : NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wifiIcon.isHidden = true
        wifiText.isHidden = true
        
        NetworkManager.isUnreachable { _ in
            self.showOffline()
        }
        NetworkManager.isReachable { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "navController", sender: self)
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func showOffline() {
        wifiIcon.isHidden = false
        wifiText.isHidden = false
        network.reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "navController", sender: self)
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
