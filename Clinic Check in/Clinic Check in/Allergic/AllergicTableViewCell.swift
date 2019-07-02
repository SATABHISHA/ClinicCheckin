//
//  AllergicTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 11/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol AllergicTableViewCellDelegate : class {
    func allergicTableViewCellDidTapEdit(_ sender: AllergicTableViewCell)
    func allergicTableViewCellDidTapDelete(_ sender: AllergicTableViewCell)
}
class AllergicTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var DisplayAllergic: UILabel!
    @IBOutlet weak var DisplayReactions: UILabel!
    @IBOutlet weak var DisplayOnset: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    weak var delegate: AllergicTableViewCellDelegate?
    @IBAction func btnEdit(_ sender:UIButton){
        delegate?.allergicTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton){
        delegate?.allergicTableViewCellDidTapDelete(self)
    }
    
}
