//
//  HistoryTableViewCell.swift
//  OnCampus
//
//  Created by Jacob van Steyn on 9/25/18.
//  Copyright © 2018 Jacobvs. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var timeOut: UILabel!
    @IBOutlet var caret: UIImageView!
    @IBOutlet var destination: UILabel!
    @IBOutlet var transportMethod: UILabel!
    @IBOutlet var signOut: UILabel!
    @IBOutlet var expectedReturn: UILabel!
    @IBOutlet var signIn: UILabel!
    
    var isSmall = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.clipsToBounds = true
    }
    
    func setupCell() {
//        self.destination.isHidden = true
//        self.transportMethod.isHidden = true
//        self.signOut.isHidden = true
//        self.expectedReturn.isHidden = true
//        self.signIn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        let rotAngle = selected ? CGFloat.pi/2 : -CGFloat.pi/2
//        self.destination.isHidden = selected ? false : true
//        self.transportMethod.isHidden = selected ? false : true
//        self.signOut.isHidden = selected ? false : true
//        self.expectedReturn.isHidden = selected ? false : true
//        self.signIn.isHidden = selected ? false : true
//        UIView.animate(withDuration: 0.5) {
//            self.caret.transform = CGAffineTransform(rotationAngle: rotAngle)
//        }
        super.setSelected(selected, animated: animated)
    }
    
    func getSize() -> CGFloat {
        if destination.isHidden{
            return CGFloat.init(exactly: 41)!
        }
        return CGFloat.init(exactly: 140)!
    }

}
