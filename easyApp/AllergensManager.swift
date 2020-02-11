//
//  AllergensDescription.swift
//  easyApp
//
//  Created by tbidn001 on 21.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import Foundation


class AllergensManager{
    
    var descriptonDictionary = [
        "gluten": ["gluten","weizen", "roggen", "gerste", "hafer", "dinkel" ],
        "fisch": ["fisch", "fischerzeugnis", "lachs", "scholle", "hering", "makrele", "thunfisch", "sardine", "sardelle" ],
        "schalenfrüchte": ["schalenfrüchte", "mandel", "haseln", "waln", "kaschun", "cashew","pistazien", "macadamian", "paran", "nuss", "nüsse"],
        "schalenfruechte": ["schalenfruechte", "mandel", "haseln", "waln", "kaschun", "cashew","pistazien", "macadamian", "paran", "nuss", "nuesse"],
        "laktose": ["lactose", "laktose"]
    ]
    
    
    func searchForAllergens(ingredients: String, myAllergies: [Allergy]) -> Bool{
        
        for allergy in myAllergies{
            if(descriptonDictionary[allergy.allergyName!.lowercased()] != nil){
                    let allergens = descriptonDictionary[allergy.allergyName!.lowercased()]

                    for allergen in allergens!{
                       
                        print(allergen)
                        
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
       
        var containsAllergens: Bool = false
        
        containsAllergens = searchForAllergens(ingredients: provision.allergens!, myAllergies: myAllergies)
        
        if containsAllergens {
            return true
        }
        
        containsAllergens = searchForAllergens(ingredients: provision.ingredients!, myAllergies: myAllergies)
        
        if containsAllergens {
            return true
        }
        
        
        return false
    }
}
