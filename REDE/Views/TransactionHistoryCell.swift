//
//  TransactionHistoryCell.swift
//  REDE
//
//  Created by Riddhi Makwana on 19/12/23.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {

    @IBOutlet weak var vwMain : UIView!
    @IBOutlet weak var lblId : UILabel!
    @IBOutlet weak var lblSiteName : UILabel!
    @IBOutlet weak var lblChargerName : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var lblEnegeryDelivered : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
