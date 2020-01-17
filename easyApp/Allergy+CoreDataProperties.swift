//
//  Allergy+CoreDataProperties.swift
//  easyApp
//
//  Created by tbidn001 on 08.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//
//

import Foundation
import CoreData


extension Allergy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Allergy> {
        return NSFetchRequest<Allergy>(entityName: "Allergy")
    }

    @NSManaged public var allergyName: String?
    @NSManaged public var isEditable: Bool
    @NSManaged public var isChosen: Bool
}
