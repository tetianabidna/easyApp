//
//  ResultViewController.swift
//  easyApp
//
//  Created by tbidn001 on 16.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit
import CoreData

class ResultViewController: UIViewController {
    
    var barcodeValue: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func searchAllergiesInProvision(provision: Provision) -> Bool{
        
        let myAllergies:[Allergy] = loadAllergiesFromDB()
        let provision: Provision = searchForElementInDB(barcodeValue: barcodeValue!)
        var containsAllergens: Bool = false
        
        //hier kommt ein 
        
        return true
    }
    
    // DB
        // search one element in DB
        func searchForElementInDB(barcodeValue: String) -> Provision{
            
            var result: Provision?
           
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                
                do {
                    let fetchRequest : NSFetchRequest<Provision> = Provision.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcodeValue)
                    
                    let fetchedResults: [Provision] = try context.fetch(fetchRequest)
                    
                    if (fetchedResults.count > 1){
                        print("Mehrere Elemente wurden in Provisions gefunden :( ")
                    }
                    result = fetchedResults[0]
                }
                catch {
                    print ("fetch task failed", error)
                }
            }
            
            return result!
        }
    
    func loadAllergiesFromDB() -> [Allergy] {
        print("load")
        var results: [Allergy] = [Allergy]()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Allergy> = Allergy.fetchRequest()
            
            do{
                results = try context.fetch(request)
            }catch{
                
            }
            
        }
        
        
        return results
    }
}
