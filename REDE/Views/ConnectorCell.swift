//
//  ConnectorCell.swift
//  REDE
//
//  Created by Avishek on 07/08/22.
//

import UIKit

class ConnectorCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblOutputPower: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    

    public func showCheck(){
        //self.checkImageView.isHidden = false
        self.checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    public func hideCheck(){
        //self.checkImageView.isHidden = true
        self.checkImageView.image = UIImage(systemName: "circle")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
    }
}
