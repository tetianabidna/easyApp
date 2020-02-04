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
    var cdFunctions: CoreDataFunctions?
    
    var provision: Provision?
    var isRed = false;
    var swipeLeft: UISwipeGestureRecognizer?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        self.cdFunctions = CoreDataFunctions(context: context!)
        
        decideWhichScreen()
        
        provisionName.text = provision!.name
        provisionImg.image = UIImage(named: provision!.picture!)
        provisionAllergens.text = provision!.allergens!
        provisionIngredients.text = provision!.ingredients!
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        if(swipeLeft != nil){
            doSwipeImgAnimation()
        }
    }
    
    //decides if the decision screen is red or green.
    //if red there is also a gesture recognizer(swipe) on the screen for the alternatives
    func decideWhichScreen(){
        
        let myAllergies:[Allergy] = cdFunctions!.loadChosenAllergies()
        
        let allergensManager = AllergensManager()
        
        let containsAllergens: Bool = allergensManager.searchAllergiesInProvision(provision: provision!, myAllergies: myAllergies)
        
        if containsAllergens{
            
            picture.image = UIImage(named: "red")
            okMark.image = UIImage(named: "notOk")
            
            isRed = true
            
            swipeLeftImg.isHidden = false
            swipeLabel.isHidden = false
            
            swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            swipeLeft!.direction = .left
            view.addGestureRecognizer(swipeLeft!)
        }else{
            
            picture.image = UIImage(named: "green")
            okMark.image = UIImage(named: "OK")
            
            swipeLeftImg.isHidden = true
            swipeLabel.isHidden = true
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        
        if sender.state == .ended{
            performSegue(withIdentifier: "toAlternatives", sender: self)
        }
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
                
                self.provisionImg.transform = CGAffineTransform(scaleX: 2.1, y: 2.1).concatenating(CGAffineTransform(translationX: -(screenWidth/2.0 - self.provisionImg.frame.width/2.0 - 10), y: self.provisionImg.frame.height + self.navigationController!.navigationBar.frame.height + self.swipeButton.frame.height + 10 - self.provisionImg.center.y))
                
                self.provisionName.transform = CGAffineTransform(translationX: 0, y: self.provisionImg.frame.maxY + 10 - self.provisionName.frame.minY)
                
                self.provisionScrollView.transform = CGAffineTransform(translationX: 0, y: self.provisionScrollView.center.y - 500 - self.provisionScrollView.frame.height - self.provisionImg.frame.maxY + 30)
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
            
            if(isRed){
                swipeLeft?.isEnabled = true
                swipeLeftImg.isHidden = false
                swipeLabel.isHidden = false
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "toAlternatives"){
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destinationVC = segue.destination as! AlternativesViewController
            
            destinationVC.provision = self.provision
        }
    }
}
