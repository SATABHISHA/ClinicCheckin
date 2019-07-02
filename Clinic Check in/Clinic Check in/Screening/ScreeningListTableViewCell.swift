//
//  ScreeningListTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 26/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol ScreeningListTableViewCellDelegate : class {
    func screeningListTableViewCellDidTapScreening(_ sender: ScreeningListTableViewCell)
    
}
class ScreeningListTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
    
    @IBOutlet weak var labelScreeningList: UILabel!
    @IBOutlet weak var labelTimeTaken: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    weak var delegate: ScreeningListTableViewCellDelegate?
    @IBAction func btnDoScreen(_ sender: UIButton) {
        delegate?.screeningListTableViewCellDidTapScreening(self)
    }
}
