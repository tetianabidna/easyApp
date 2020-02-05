//
//  MyAllergiesTableViewCell.swift
//  easyApp
//
//  Created by tbidn001 on 07.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit

protocol RemoveModelDelegate : class{
    func removeModel(currentCell: MyAllergiesTableViewCell)
}

class MyAllergiesTableViewCell: UITableViewCell {
    
    var model: UIMyAllergyModel?{
        didSet{
            
            allergieName.text = model?.allergyName

        }
    }
    
    weak var delegate: RemoveModelDelegate?
    
    @IBOutlet weak var allergieName: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func deleteAllergie(_ sender: Any) {
        
        delegate?.removeModel(currentCell: self)
    }
}
