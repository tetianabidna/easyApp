//
//  AllAllergiesTableViewCell.swift
//  easyApp
//
//  Created by tbidn001 on 07.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit

protocol AllAllergRemoveModelDelegate : class{
    func removeModel(currentCell: AllAllergiesTableViewCell)
    func editModel(currentCell: AllAllergiesTableViewCell)
}

class AllAllergiesTableViewCell: UITableViewCell {
    
    var model: UIAllAllergieModel?{
        didSet{
            allergieName.text = model?.allergieName
        }
    }

    weak var delegate: AllAllergRemoveModelDelegate?
    
    @IBOutlet weak var butRemove: UIButton!
    @IBOutlet weak var butEdit: UIButton!
    @IBAction func removeAllergy(_ sender: Any) {
        
        delegate?.removeModel(currentCell: self)
    }
    
    @IBAction func editAllergy(_ sender: Any) {
        delegate?.editModel(currentCell: self)
    }
    @IBOutlet weak var allergieName: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
