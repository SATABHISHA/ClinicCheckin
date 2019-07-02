//
//  FinancialHomeTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 25/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol FinancialHomeTableViewCellDelegate : class {
    func financialHomeTableViewCellDidTapEdit(_ sender: FinancialHomeTableViewCell)
    func financialHomeTableViewCellDidTapDelete(_ sender: FinancialHomeTableViewCell)
    
}
class FinancialHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var DisplayTableCellView: UIView!
    
    
    @IBOutlet weak var labelAcntHolder: UILabel!
    @IBOutlet weak var inputAcntHolder: UILabel!
    
    @IBOutlet weak var labelAcntType: UILabel!
    @IBOutlet weak var inputAcntType: UILabel!
    
    @IBOutlet weak var labelBankAcntPatientName: UILabel!
    @IBOutlet weak var inputBankAcntPatientName: UILabel!
    
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var inputCardNo: UILabel!
    
    @IBOutlet weak var labelExpiryDate: UILabel!
    @IBOutlet weak var inputExpiryDate: UILabel!
    
    @IBOutlet weak var labelCardIdNo: UILabel!
    @IBOutlet weak var inputCardIdNo: UILabel!
    
    @IBOutlet weak var labelBillingZipCode: UILabel!
    @IBOutlet weak var inputBillingZipCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    weak var delegate: FinancialHomeTableViewCellDelegate?
    @IBAction func btnEdit(_ sender: UIButton) {
         delegate?.financialHomeTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
         delegate?.financialHomeTableViewCellDidTapDelete(self)
    }
}
