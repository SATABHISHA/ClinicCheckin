//
//  ContactTableViewCell.swift
//  Clinic Check in
//
//  Created by MK on 11/05/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

/*protocol CellSubclassDelegate: class {
    func actionEditContact(cell: ContactTableViewCell, action: String)
}*/
protocol ContactTableViewCellDelegate : class {
    func contactTableViewCellDidTapEdit(_ sender: ContactTableViewCell)
    func contactTableViewCellDidTapDelete(_ sender: ContactTableViewCell)
}
class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var DisplayTableCellView: UIView!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var DisplayPhoneNo: UILabel!
    @IBOutlet weak var DisplayEmail: UILabel!
    @IBOutlet weak var DisplayAddress: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  /*  var delegate: CellSubclassDelegate?
    @IBAction func editContactBtn(sender: UIButton) {
        self.delegate?.actionEditContact(cell: self, action: "Edit")
        
    }
    @IBAction func deleteContactBtn(sender: UIButton) {
        self.delegate?.actionEditContact(cell: self, action: "Edit")
    }*/
  weak var delegate: ContactTableViewCellDelegate?
   /* @IBAction func btn_edit(_ sender: UIButton) {
       delegate?.contactTableViewCellDidTapEdit(self)
    }
    
    @IBAction func btn_delete(_ sender: UIButton) {
         delegate?.contactTableViewCellDidTapDelete(self)
    }*/
    @IBAction func btnEdit(_ sender: UIButton){
        delegate?.contactTableViewCellDidTapEdit(self)
    }
    @IBAction func btnDelete(_ sender: UIButton){
        delegate?.contactTableViewCellDidTapDelete(self)
    }
    
}
