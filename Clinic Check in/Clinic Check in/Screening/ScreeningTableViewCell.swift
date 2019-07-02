//
//  ScreeningTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 02/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol ScreeningTableViewCellDelegate : class {
    func screeningTableViewCellDidTapSelectAnswer(_ sender: ScreeningTableViewCell)
}
class ScreeningTableViewCell: UITableViewCell {
    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var labelScreeningQuestion: UILabel!
    
    @IBOutlet weak var labelSelectedAnswer: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 weak var delegate: ScreeningTableViewCellDelegate?
    
    @IBAction func btnSelectAnswer(_ sender: UIButton) {
    delegate?.screeningTableViewCellDidTapSelectAnswer(self)
    }
}
