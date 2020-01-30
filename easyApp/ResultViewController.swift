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
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
    var barcodeValue: String?
    var provision: Provision?

    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var provisionName: UILabel!
    @IBOutlet weak var provisionImg: UIImageView!
    
    @IBOutlet weak var provisionScrollView: UIScrollView!
    @IBOutlet weak var provisionDetails: UIView!
    
    @IBOutlet weak var provisionIngridients: UITextView!
    @IBOutlet weak var provisionAllergies: UITextView!
    
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var swipeButton: UIButton!
    
    @IBOutlet weak var darkView: UIViewX!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        
        let containsAllergens: Bool = searchAllergiesInProvision(provision: provision!, barcode: barcodeValue!)
        
        if containsAllergens{
            picture.image = UIImage(named: "red-1")
        }else{
            picture.image = UIImage(named: "green-1")
        }
        doGradientAnimation()
        
        provisionName.text = provision!.name
        provisionImg.image = UIImage(named: provision!.picture!)
        provisionIngridients.text = provision!.ingredients!
        
        provisionAllergies.text = provision!.allergens!
    }
    
    func doGradientAnimation(){
        
        print("in animation")
        self.picture.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 2, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let x = -self.picture.frame.width + self.view.frame.width
            self.picture.transform = CGAffineTransform(translationX: x, y: 0)
        })
    }
    
    @IBAction func showDetails(_ sender: Any) {
       
            if darkView.transform == CGAffineTransform.identity{
                UIView.animate(withDuration: 1, animations: {
                    
                    let screenHeight = self.view.frame.height
                    let screenWidth = self.view.frame.width
                    
                   self.darkView.transform = CGAffineTransform(scaleX: 30, y: 30)
                   self.swipeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                   
                   self.detailsView.transform = CGAffineTransform(translationX: 0, y: -(screenHeight - self.detailsView.frame.height - self.navigationController!.navigationBar.frame.height)) // 65 is the navigation bar
                   self.detailsView.frame.size.height += 500
                    
                    self.provisionImg.transform = CGAffineTransform(scaleX: 3, y: 3).concatenating(CGAffineTransform(translationX: -(screenWidth/2.0 - self.provisionImg.frame.width/2.0 - 10), y: self.provisionImg.frame.height + self.navigationController!.navigationBar.frame.height + self.swipeButton.frame.height + 10 - self.provisionImg.center.y))

                    self.provisionName.transform = CGAffineTransform(translationX: 0, y: self.provisionImg.frame.maxY + 10 - self.provisionName.frame.minY)

                    self.provisionScrollView.transform = CGAffineTransform(translationX: 0, y: self.provisionScrollView.center.y - 500 - self.provisionScrollView.frame.height - self.provisionImg.frame.maxY + 10)
                    
                    /*
                    self.darkView.transform = CGAffineTransform(scaleX: 30, y: 30)
                    self.swipeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    
                    self.detailsView.transform = CGAffineTransform(translationX: 0, y: -400)
                    self.detailsView.frame.size.height += 500

                    self.provisionName.transform = CGAffineTransform(translationX: 20, y: 230)
                    
                    self.provisionImg.transform = CGAffineTransform(translationX: -50, y: 30).concatenating(CGAffineTransform(scaleX: 3, y: 3))

                    self.provisionScrollView.transform = CGAffineTransform(translationX: 0, y: -250)
                    */
                })
        } else{
            UIView.animate(withDuration: 1, animations: {
                           
                self.provisionScrollView.transform = .identity
                self.provisionImg.transform = .identity
                self.provisionName.transform = .identity
                self.detailsView.frame.size.height -= 500
                self.detailsView.transform = .identity
                self.swipeButton.transform = .identity
                self.darkView.transform = .identity
            })
        }
    }
            

      
    
    func searchAllergiesInProvision(provision: Provision, barcode: String) -> Bool{
        
        print("searchAllergiesInProvision")
        
        
        // 2.Load myAllergies
        let myAllergies:[Allergy] = searchForElementInDB()
        
        
        let allergenManager = AllergensDescription()
        
        var containsAllergens: Bool = false
        
        print(provision.allergens!)
        containsAllergens = allergenManager.searchForAllergens(ingredients: provision.allergens!, myAllergies: myAllergies)
        
        if containsAllergens {
            print("Allergene gefunden")
            return true
        }
        
        print(provision.ingredients!)
        containsAllergens = allergenManager.searchForAllergens(ingredients: provision.ingredients!, myAllergies: myAllergies)
        
        if containsAllergens {
            print("Allergene gefunden")
            return true
        }
        
        print("keine Allergene")
        
        
        return false
    }
    
    // DB
    
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
}
