//
//  CardTableViewCell.swift
//  REDE
//
//  Created by Riddhi Makwana on 19/01/24.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    @IBOutlet weak var vwMain : UIView!
    @IBOutlet weak var lblCard : UILabel!
    @IBOutlet weak var lblExp : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
