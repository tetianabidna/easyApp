//
//  CoreDataFunctions.swift
//  easyApp
//
//  Created by tbidn001 on 04.02.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataFunctions{
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    func saveContext(){
        
        do {
            try context.save()
            
        } catch{
            print(error)
        }
        
        print("saved successfully")
    }
    
    func deleteAll(from entityName: String) {
            
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
        
        print("deleted successfully")
    }
    
    func loadAll(from entityName: String) -> [NSManagedObject] {
        
        var results: [NSManagedObject] = [NSManagedObject]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
            
            do{
                results = try context.fetch(request) as! [NSManagedObject]
            }catch{}
        
        
        return results
    }
    
    func searchForElementInAllergy(allergyName: String) -> NSManagedObject{
        
        var output:NSManagedObject?
        
        //Make request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
        
        if let allergies = try! context.fetch(request) as? [Allergy] {
            allergies.forEach({
                if($0.allergyName == allergyName){
                    
                    output = $0
                }
            })
        }
        
        return output!
    }
    
    func loadChosenAllergies() -> [Allergy]{

      var result: [Allergy] = [Allergy]()
      
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
      
      let allergies = try! context.fetch(request) as? [Allergy]
      
      allergies!.forEach({
           if($0.isChosen){
              
              result.append($0)
           }
       })
      
        
      return result
    }
    
    func searchForProvisionsInCategory(category: String) -> [Provision]?{
        
        var fetchedResults: [Provision]?
        
        
        do {
            let fetchRequest : NSFetchRequest<Provision> = Provision.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == %@", category)
            
            fetchedResults = try context.fetch(fetchRequest)
            
        }
        catch {
            print ("fetch task failed", error)
        }
        
        
        return fetchedResults
    }
}
