//
//  SiteDetailTableViewCell.swift
//  REDE
//
//  Created by Riddhi Makwana on 03/01/24.
//

import UIKit

class SiteDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lbloutput : UILabel!
    @IBOutlet weak var lblConnection1 : UILabel!
    @IBOutlet weak var lblConnection1KW : UILabel!
    @IBOutlet weak var lblConnection2 : UILabel!
    @IBOutlet weak var lblConnection2KW : UILabel!
    @IBOutlet weak var stackView1 : UIStackView!
    @IBOutlet weak var stackView2 : UIStackView!
    @IBOutlet weak var vwMain : UIView!
    @IBOutlet weak var vwPoint1 : UIView!
    @IBOutlet weak var vwPoint2 : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
