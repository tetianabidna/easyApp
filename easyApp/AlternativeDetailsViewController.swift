//
//  AlternativeDetailsViewController.swift
//  easyApp
//
//  Created by tbidn001 on 05.02.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit

class AlternativeDetailsViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ingredients: UITextView!
    @IBOutlet weak var allergens: UITextView!
    
    var provision: Provision!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img.image = UIImage(named: provision.picture!)
        name.text = provision.name
        ingredients.text = provision.ingredients
        allergens.text = provision.allergens
    }
}

