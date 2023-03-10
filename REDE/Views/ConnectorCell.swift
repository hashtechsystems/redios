//
//  ConnectorCell.swift
//  REDE
//
//  Created by Avishek on 07/08/22.
//

import UIKit

class ConnectorCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var checkImageView: UIImageView!
    

    public func showCheck(){
        //self.checkImageView.isHidden = false
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    public func hideCheck(){
        self.checkImageView.isHidden = true
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
    }
}
