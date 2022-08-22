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
    
    var connector: Connector?
    
    public func toggleSelected() {
        if (isSelected) {
            self.checkImageView.isHidden = false
        }else{
            self.checkImageView.isHidden = true
        }
    }
}
