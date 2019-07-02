//
//  GoalTableViewCell.swift
//  Clinic Check in
//
//  Created by Satabhisha on 03/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

protocol GoalTableViewCellDelegate : class {
    func goalTableViewCellDidTapSlider(_ sender: GoalTableViewCell)
}
class GoalTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var labelGoalName: UILabel!
    @IBOutlet weak var sliderRating: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    weak var delegate: GoalTableViewCellDelegate?
    
    @IBAction func actionTouchInside(_ sender: UISlider) {
        delegate?.goalTableViewCellDidTapSlider(self)
    }
    
}
