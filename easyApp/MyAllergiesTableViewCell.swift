//
//  MyAllergiesTableViewCell.swift
//  easyApp
//
//  Created by tbidn001 on 12.12.19.
//  Copyright © 2019 tbidn001. All rights reserved.
//

import UIKit

protocol RemoveModelDelegate : class{
    func removeModel(currentCell: MyAllergiesTableViewCell)
}

class MyAllergiesTableViewCell: UITableViewCell {

    weak var delegate: RemoveModelDelegate?
    
    @IBOutlet weak var allergieName: UILabel!
    
    @IBAction func deleteAllergie(_ sender: Any) {
        
        delegate?.removeModel(currentCell: self)
    }
    
    var model: UIAllergieModel?{
        didSet{
            allergieName.text = model?.allergieName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
