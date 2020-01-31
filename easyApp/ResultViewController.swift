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
    
    @IBOutlet weak var provisionAllergens: UITextView!
    @IBOutlet weak var provisionIngredients: UITextView!
    
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var swipeButton: UIButton!
    
    @IBOutlet weak var darkView: UIViewX!
    
    @IBOutlet weak var okMark: UIImageView!
    @IBOutlet weak var swipeLeftImg: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    var swipeLeft: UISwipeGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        
        // 2.Load myAllergies
        let myAllergies:[Allergy] = searchForElementInDB()
        
        let allergensDescription = AllergensDescription()
        
        
        let containsAllergens: Bool = allergensDescription.searchAllergiesInProvision(provision: provision!, myAllergies: myAllergies)
        
        if containsAllergens{
            picture.image = UIImage(named: "red-1")
            okMark.image = UIImage(named: "notOk")
            swipeLeftImg.isHidden = false
            swipeLabel.isHidden = false
            
            swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            swipeLeft!.direction = .left
            view.addGestureRecognizer(swipeLeft!)
            
        }else{
            picture.image = UIImage(named: "green-1")
            okMark.image = UIImage(named: "OK")
            
            swipeLeftImg.isHidden = true
            swipeLabel.isHidden = true

        }
        doGradientAnimation()
        
        provisionName.text = provision!.name
        provisionImg.image = UIImage(named: provision!.picture!)
        provisionAllergens.text = provision!.allergens!
        
        provisionIngredients.text = provision!.ingredients!
    }
    
    override func viewWillAppear(_ animated: Bool){
        print("*** IndexViewController")

        if(swipeLeft != nil){
            doSwipeImgAnimation()
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            performSegue(withIdentifier: "toAlternatives", sender: self)
        }
    }
    
    func doGradientAnimation(){
        
        print("in animation")
        self.picture.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 10, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.picture.frame.height - self.view.frame.height
            self.picture.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
    
    func doSwipeImgAnimation(){
        UIView.animate(withDuration: 1.5, delay:0, options: [.curveLinear, .repeat], animations: {
            
            self.swipeLeftImg.transform = CGAffineTransform(translationX: -60, y:0 )
            self.swipeLeftImg.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            self.swipeLeftImg.alpha = 1
            self.swipeLeftImg.transform = .identity
        })
    }
    
    @IBAction func showDetails(_ sender: Any) {
            
            if darkView.transform == CGAffineTransform.identity{
                
                swipeLeftImg.isHidden = true
                swipeLabel.isHidden = true
                swipeLeft?.isEnabled = false
                
                UIView.animate(withDuration: 1, animations: {
                    
                    self.okMark.alpha = 0
                    
                    let screenHeight = self.view.frame.height
                    let screenWidth = self.view.frame.width
                    
                   self.darkView.transform = CGAffineTransform(scaleX: 30, y: 30)
                   self.swipeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                   
                   self.detailsView.transform = CGAffineTransform(translationX: 0, y: -(screenHeight - self.detailsView.frame.height - self.navigationController!.navigationBar.frame.height)) // 65 is the navigation bar
                   self.detailsView.frame.size.height += 500
                    
                    self.provisionImg.transform = CGAffineTransform(scaleX: 3, y: 3).concatenating(CGAffineTransform(translationX: -(screenWidth/2.0 - self.provisionImg.frame.width/2.0 - 10), y: self.provisionImg.frame.height + self.navigationController!.navigationBar.frame.height + self.swipeButton.frame.height + 10 - self.provisionImg.center.y))

                    self.provisionName.transform = CGAffineTransform(translationX: 0, y: self.provisionImg.frame.maxY + 10 - self.provisionName.frame.minY)

                    self.provisionScrollView.transform = CGAffineTransform(translationX: 0, y: self.provisionScrollView.center.y - 500 - self.provisionScrollView.frame.height - self.provisionImg.frame.maxY + 20)
                    
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
                
                self.okMark.alpha = 1
            })
                swipeLeft?.isEnabled = true

                swipeLeftImg.isHidden = false
                swipeLabel.isHidden = false
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "toAlternatives"){
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC = segue.destination as! AlternativesViewController
        
        destinationVC.provision = self.provision
        
    }
    }
}
