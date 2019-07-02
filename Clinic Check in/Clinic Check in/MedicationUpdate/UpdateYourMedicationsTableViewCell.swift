//
//  UpdateYourMedicationsTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 14/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit


protocol UpdateYourMedicationsTableViewCellDelegate : class {
    func updateYourMedicationsTableViewCellDidTapEdit(_ sender: UpdateYourMedicationsTableViewCell)
    func updateYourMedicationsTableViewCellDidTapDelete(_ sender: UpdateYourMedicationsTableViewCell)
    func updateYourMedicationsTableViewCellDidTapAddSideEffects(_ sender: UpdateYourMedicationsTableViewCell)
}
class UpdateYourMedicationsTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
     @IBOutlet weak var displayMedicationName: UILabel!
    @IBOutlet weak var displayDosageOfMedication: UILabel!
    @IBOutlet weak var displayStartDate: UILabel!
    @IBOutlet weak var displayDiscontinuedDate: UILabel!
    @IBOutlet weak var displaySideEffects: UILabel!
    
    @IBOutlet weak var editBtnView: UIButton!
    @IBOutlet weak var deleteBtnView: UIButton!
    @IBOutlet weak var addSideEffectsbtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    weak var delegate: UpdateYourMedicationsTableViewCellDelegate?
    @IBAction func btnEdit(_ sender: UIButton) {
        delegate?.updateYourMedicationsTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        delegate?.updateYourMedicationsTableViewCellDidTapDelete(self)
    }
    
    @IBAction func btnAddSideEffects(_ sender: UIButton) {
        delegate?.updateYourMedicationsTableViewCellDidTapAddSideEffects(self)
    }
}
