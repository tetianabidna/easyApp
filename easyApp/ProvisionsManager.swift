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
    
    init(context: NSManagedObjectContext){
        print("ProvisionsManager")
        
        self.context = context
        print("******************")
        deleteAllFromTable()
        
        readDataFromJSON()
    }
    
    func readDataFromJSON(){
        
        if let path = Bundle.main.path(forResource: "provisions", ofType: "json") {
            
            print("path to JSON Data:   \(path)")
            
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                print ("data \(data != nil)")
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print ("jsonResult \(jsonResult != nil)")
                print(jsonResult)
                
                let jsonResult1 = jsonResult as? Dictionary<String, AnyObject>
                print(jsonResult1)
                
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let provisions = jsonResult["provisions"] as? [Any] {
                    
                    for provision1 in provisions{
                        
                        var provision: Dictionary<String, String> = provision1 as! Dictionary<String, String>
                        
                        print(provision)
                        let name = provision["name"] as! String
                        print(name)
                        
                        let barcode = provision["barcode"] as! String
                        print(barcode)
                        
                        let ingredients = provision["ingredients"] as! String
                        print(ingredients)
                        
                        let allergens = provision["allergens"] as! String
                        print(allergens)
                        
                        let category = provision["category"] as! String
                        print(category)
                        
                        let picture = provision["picture"] as! String
                        print(picture)
                        
                        saveDataInDB(name: name, barcode: barcode, ingredients: ingredients, allergens: allergens, category: category, picture: picture)
                        
                        
                    }
                            
                  }else{
                    print("nicht geklappt")
                }
              } catch {
                
                   print(error)
              }
        }else{
            print("not founded")
        }
    }
    
    // DB
    func saveDataInDB(name: String, barcode: String, ingredients: String, allergens: String, category: String, picture: String){
        let newProvision = Provision(context: context)
        newProvision.name = name
        newProvision.barcode = barcode
        newProvision.ingredients = ingredients
        newProvision.allergens = allergens 
        newProvision.category = category
        newProvision.picture = picture

        do {
            try context.save()
            print("saved successfuly: \(newProvision.toString())")
        } catch{
            print(error)
        }
    }
    
    func deleteAllFromTable() {
            
            let entityName = "Provision"
            
            //Make request
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            do{
                let results = try context.fetch(request)
                
                for r in results{
                    if let result = r as? NSManagedObject{
                        context.delete(result)
                    }
                }
            }catch{
                print(error)
            }
        
        print("deleted successfuly: all elements")
    }
    
    func loadNamesFromDB() -> [Provision] {
        print("load")
        var results: [Provision] = [Provision]()
        
            let request: NSFetchRequest<Provision> = Provision.fetchRequest()
            
            do{
                results = try context.fetch(request)
            }catch{
                
            }
        
        
        return results
    }
}
