//
//  PharmacyTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 04/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol PharmacyTableViewCellDelegate : class {
    func pharmacyTableViewCellDidTapEdit(_ sender: PharmacyTableViewCell)
    func pharmacyTableViewCellDidTapDelete(_ sender: PharmacyTableViewCell)
    
}
class PharmacyTableViewCell: UITableViewCell {
    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var inputTablecell1: UILabel!
    @IBOutlet weak var inputTablecell2: UILabel!
    @IBOutlet weak var inputTablecell3: UILabel!
    @IBOutlet weak var inputTablecell4: UILabel!
    @IBOutlet weak var inputTablecell5: UILabel!
    @IBOutlet weak var inputTablecell6: UILabel!
    
    @IBOutlet weak var labelTablecell1: UILabel!
    @IBOutlet weak var labelTablecell2: UILabel!
    @IBOutlet weak var labelTablecell3: UILabel!
    @IBOutlet weak var labelTablecell4: UILabel!
    @IBOutlet weak var labelTablecell5: UILabel!
    @IBOutlet weak var labelTablecell6: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

     weak var delegate: PharmacyTableViewCellDelegate?
    @IBAction func btnEdit(_ sender: UIButton) {
         delegate?.pharmacyTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        delegate?.pharmacyTableViewCellDidTapDelete(self)
    }
}
