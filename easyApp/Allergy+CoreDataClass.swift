//
//  Allergy+CoreDataClass.swift
//  easyApp
//
//  Created by tbidn001 on 08.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//
//

import Foundation
import CoreData


public class Allergy: NSManagedObject {
    
    func toString(){
        print("name: \(self.allergyName),   isEditable: \(self.isEditable)  isChosen: \(self.isChosen)")
    }
}
