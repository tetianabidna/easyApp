//
//  Provision+CoreDataProperties.swift
//  easyApp
//
//  Created by tbidn001 on 16.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//
//

import Foundation
import CoreData


extension Provision {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Provision> {
        return NSFetchRequest<Provision>(entityName: "Provision")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var name: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var category: String?

}
