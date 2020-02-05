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
    var cdFunctions: CoreDataFunctions!
    
    var provision: Provision!
    var alternativeViewWidth: CGFloat?
    var provisionViewDictionary = Dictionary<String, Provision>()
    
    @IBOutlet weak var mainView: UIViewX!
    @IBOutlet weak var gradientView: UIImageView!
    @IBOutlet weak var noAlternativeText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        self.cdFunctions = CoreDataFunctions(context: context!)
        
        doGradientAnimation()
        
        self.alternativeViewWidth = (self.view.frame.width - 60) / 2.0
        
        findAlternatives()
    }
    
    func findAlternatives(){
    
        let provisionsWithSameCategory = self.cdFunctions.searchForProvisionsInCategory( category: provision.category!)
        let myAllergies:[Allergy] = self.cdFunctions.loadChosenAllergies()
        var alternatives = [Provision]()
        
        let allergensManager = AllergensManager()
        
        // search for alternatives
        for provision in provisionsWithSameCategory!{
            
            let containsAllergens = allergensManager.searchAllergiesInProvision(provision: provision, myAllergies: myAllergies)
            
            if(!containsAllergens){
                alternatives.append(provision)
            }
        }
        
        createAlternativeSubViews(for: alternatives)
    }
    
    func createAlternativeSubViews(for alternatives: [Provision]){
        
        let startXLeft: CGFloat = 20
        let startXRight: CGFloat = startXLeft + alternativeViewWidth! + 20
        
        var startY: CGFloat = 20
        
        var isLastAlternative = false
        
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
                
                provisionViewDictionary[provision.name!] = provision
            }
        }else{
            
            noAlternativeText.isHidden = false
        }
    }
    
    func addAlternativeToView(provision: Provision, startX: CGFloat, startY: CGFloat, isLastAlternative: Bool){
        
        let alternativeView = UIView()
        alternativeView.layer.cornerRadius = 10
        
        let provisionImg = UIImageView()
        provisionImg.image = UIImage(named: provision.picture!)
        provisionImg.contentMode = .scaleAspectFit
        
        let provisionName = UILabel()
        provisionName.text = provision.name
        provisionName.font = UIFont(name:"Futura", size: 20.0)
        provisionName.textColor = UIColor.white
        provisionName.adjustsFontSizeToFitWidth = true
        
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
        
        let widthLabelConstraint = NSLayoutConstraint(item: provisionName, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: alternativeView.frame.size.width - 20)
        
        alternativeView.addConstraints([topLabelConstraint,widthLabelConstraint, verticalLabelConstraint])
        
        self.mainView.addSubview(alternativeView)
        
        if(isLastAlternative){
            let bottomConstraint = NSLayoutConstraint(item: mainView as Any , attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: alternativeView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 10)
            
            mainView.addConstraint(bottomConstraint)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alternativeView.addGestureRecognizer(tap)
    }
    
    var tapName: String!
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        let label = sender?.view?.subviews.compactMap { $0 as? UILabel }
        tapName = label?.first?.text
        
        performSegue(withIdentifier: "toAlternativeDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if(segue.identifier == "toAlternativeDetails"){
               
               // Create a new variable to store the instance of PlayerTableViewController
               let destinationVC = segue.destination as! AlternativeDetailsViewController
            
               
               destinationVC.provision = self.provisionViewDictionary[tapName]
           }
       }
    
    func doGradientAnimation(){
        
        self.gradientView.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 5, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.gradientView.frame.height - self.view.frame.height
            self.gradientView.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
}
