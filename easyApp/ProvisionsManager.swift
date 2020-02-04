//
//  ProvisionsManager.swift
//  easyApp
//
//  Created by tbidn001 on 21.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class ProvisionsManager{
    
    var context: NSManagedObjectContext
    var cdFunctions: CoreDataFunctions
    
    init(context: NSManagedObjectContext){
        
        self.context = context
        self.cdFunctions = CoreDataFunctions(context: context)
            
        cdFunctions.deleteAll(from: "Provision")
        readDataAndSaveInCoreData()
    }
    
    //Reads data from provisions.json and saves it to the database
    func readDataAndSaveInCoreData(){
        
        if let path = Bundle.main.path(forResource: "provisions", ofType: "json") {
 
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
              
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
               
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let provisions = jsonResult["provisions"] as? [Any] {
                    
                    for provision1 in provisions{
                        
                        let provision: Dictionary<String, String> = provision1 as! Dictionary<String, String>
                      
                        let newProvision = Provision(context: context)
                        
                        newProvision.name = provision["name"]!
                        newProvision.barcode = provision["barcode"]!
                        newProvision.ingredients = provision["ingredients"]!
                        newProvision.allergens = provision["allergens"]!
                        newProvision.category = provision["category"]!
                        newProvision.picture = provision["picture"]!
                    }
                    
                    cdFunctions.saveContext()
                  }
              } catch {
                
                   print(error)
              }
        }else{
            print("Provisions file path was not found")
        }
    }
}
