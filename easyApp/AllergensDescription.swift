//
//  AllergensDescription.swift
//  easyApp
//
//  Created by tbidn001 on 21.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import Foundation


class AllergensDescription{
    
    var descriptonDictionary = [
        "gluten": ["gluten","weizen", "roggen", "gerste", "hafer", "dinkel" ],
        "fisch": ["fisch", "fischerzeugnis", "lachs", "scholle", "hering", "makrele", "thunfisch", "sardine", "sardelle" ],
        "schalenfrüchte": ["schalenfrüchte", "mandel", "haseln", "waln", "kaschun", "cashew","pistazien", "macadamian", "paran"],
        "schalenfruechte": ["schalenfruechte", "mandel", "haseln", "waln", "kaschun", "cashew","pistazien", "macadamian", "paran"]
    ]
    
    
    func searchForAllergens(ingredients: String, myAllergies: [Allergy]) -> Bool{
        
        for allergy in myAllergies{
            //print("allergy: \(allergy)")
            
                
                if(descriptonDictionary[allergy.allergyName!] != nil){
                   // print("is in dictionary")
                    let allergens = descriptonDictionary[allergy.allergyName!]

                    for allergen in allergens!{
                        //print("allergen: \(allergen)")
                        if(ingredients.lowercased().contains(allergen)){
                            return true
                        }
                    }
                }else{
                    if(ingredients.lowercased().contains(allergy.allergyName!.lowercased())){
                        return true
                    }
                }
            
        }
    
        
        return false
    }
    
    func searchAllergiesInProvision(provision: Provision, myAllergies:[Allergy]) -> Bool{
        
        //print("searchAllergiesInProvision")
        
        var containsAllergens: Bool = false
        
        //print(provision.allergens!)
        containsAllergens = searchForAllergens(ingredients: provision.allergens!, myAllergies: myAllergies)
        
        if containsAllergens {
        //    print("Allergene gefunden")
            return true
        }
        
        //print(provision.ingredients!)
        containsAllergens = searchForAllergens(ingredients: provision.ingredients!, myAllergies: myAllergies)
        
        if containsAllergens {
        //    print("Allergene gefunden")
            return true
        }
        
        //print("keine Allergene")
        
        
        return false
    }
}
