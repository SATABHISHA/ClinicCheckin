//
//  LifeEventTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 18/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit


protocol LifeEventTableViewCellDelegate : class {
    func updateLifeEventDetailsTableViewCellDidTapEdit(_ sender: LifeEventTableViewCell)
    func updateLifeEventDetailsTableViewCellDidTapDelete(_ sender: LifeEventTableViewCell)
   
}
class LifeEventTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var displayEvent: UILabel!
    @IBOutlet weak var displayAffect: UILabel!
    @IBOutlet weak var displayStartDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var delegate: LifeEventTableViewCellDelegate?
    @IBAction func btnEdit(_ sender: UIButton) {
        delegate?.updateLifeEventDetailsTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        delegate?.updateLifeEventDetailsTableViewCellDidTapDelete(self)
    }

}
