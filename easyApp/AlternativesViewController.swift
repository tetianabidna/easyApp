//
//  AlternativesViewController.swift
//  easyApp
//
//  Created by tbidn001 on 31.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit
import CoreData

class AlternativesViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
    var provision: Provision!
    
    var alternativeViewWidth: CGFloat?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gradientView: UIImageView!
    @IBOutlet weak var noAlternativeText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doGradientAnimation()
        
        context = appDelegate?.persistentContainer.viewContext
        
        self.alternativeViewWidth = (self.view.frame.width - 60) / 2.0

        //provision = searchForElementInDB()
        
        //addAlternativeToView(provision: provision, startX: 20.0, startY: 20.0)
        
        findAlternatives()
    }
    
    func findAlternatives(){
        
        var provisionsSameCategory = searchForElementsInDB( category: provision.category!)
        
        // 2.Load myAllergies
        let myAllergies:[Allergy] = searchForElementInDB()
        
        let allergensDescription = AllergensDescription()
        
        let startXLeft: CGFloat = 20
        let startXRight: CGFloat = startXLeft + alternativeViewWidth! + 20
        
        var startY: CGFloat = 20
        
        var isLastAlternative = false
        
        var alternatives = [Provision]()
        
        
        // search for alternatives
        for provision in provisionsSameCategory!{
            
            let containsAllergens = allergensDescription.searchAllergiesInProvision(provision: provision, myAllergies: myAllergies)
            
            if(!containsAllergens){
                alternatives.append(provision)
            }
        }
        
        // create alternative views
        
        if(alternatives.count != 0){
            noAlternativeText.isHidden = true
            
            let lastAlternativeIndex = alternatives.count - 1
            
            for (index, provision) in alternatives.enumerated(){
                
                isLastAlternative = (index == lastAlternativeIndex) ? true : false
                
                if(index%2 == 1){
                    addAlternativeToView(provision: provision, startX: startXRight, startY: startY, isLastAlternative: isLastAlternative)
                    startY += (alternativeViewWidth! + 50) + 20
                    
                }else{
                    addAlternativeToView(provision: provision, startX: startXLeft, startY: startY, isLastAlternative: isLastAlternative)
                }
            }
        }else{
            noAlternativeText.isHidden = false
        }
    }
    
    func addAlternativeToView(provision: Provision, startX: CGFloat, startY: CGFloat, isLastAlternative: Bool){
        
        let alternativeView = UIView()
        
        let provisionImg = UIImageView()
        provisionImg.image = UIImage(named: provision.picture!)
        
        let provisionName = UILabel()
        provisionName.text = provision.name
        provisionName.font = UIFont(name:"Futura", size: 20.0)
        provisionName.textColor = UIColor.white
        
        alternativeView.frame = CGRect(x: startX, y: startY, width: alternativeViewWidth! , height: alternativeViewWidth! + 50)
        
        alternativeView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5) 
        
        alternativeView.addSubview(provisionImg)
        
        provisionImg.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: provisionImg, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: alternativeView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 10)
        
        let verticalConstraint = NSLayoutConstraint(item: provisionImg, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: alternativeView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: provisionImg, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: alternativeView.frame.size.width - 20)
        
        let heightConstraint = NSLayoutConstraint(item: provisionImg, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: alternativeView.frame.size.width - 20)
        
        alternativeView.addConstraints([topConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        
        alternativeView.addSubview(provisionName)
        
        provisionName.translatesAutoresizingMaskIntoConstraints = false
        
        let topLabelConstraint = NSLayoutConstraint(item: provisionName, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: provisionImg, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 10)
        
        let verticalLabelConstraint = NSLayoutConstraint(item: provisionName, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: alternativeView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        alternativeView.addConstraints([topLabelConstraint, verticalLabelConstraint])
        
        self.mainView.addSubview(alternativeView)
        
        if(isLastAlternative){
            let bottomConstraint = NSLayoutConstraint(item: mainView , attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: alternativeView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 10)
            
            mainView.addConstraint(bottomConstraint)
        }
    }
    
    func doGradientAnimation(){
        
        self.gradientView.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 10, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.gradientView.frame.height - self.view.frame.height
            self.gradientView.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
    
    // DB
      // search one element in DB
      func searchForElementsInDB(category: String) -> [Provision]?{
    
          var fetchedResults: [Provision]?
         
          
          do {
              let fetchRequest : NSFetchRequest<Provision> = Provision.fetchRequest()
              fetchRequest.predicate = NSPredicate(format: "category == %@", category)
              
              fetchedResults = try context!.fetch(fetchRequest)
              
          }
          catch {
              print ("fetch task failed", error)
          }
          
          
          return fetchedResults
      }
    
    // search one element in DB
    func searchForElementInDB() -> [Allergy]{

      var result: [Allergy] = [Allergy]()
      
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
      
      let allergies = try! context!.fetch(request) as? [Allergy]
      
      allergies!.forEach({
           if($0.isChosen){
              
              result.append($0)
           }
       })
      
        
      return result
    }
    
    func searchForElementInDB() -> Provision{

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Provision")
      
        let allergies = try! context!.fetch(request) as? [Provision]
       
    
        return (allergies?.first)!
    }
}
