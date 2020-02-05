//
//  AllergieEditViewController.swift
//  easyApp
//
//  Created by tbidn001 on 07.01.20.
//  Copyright © 2020 tbidn001. All rights reserved.
//

import UIKit
import CoreData

// Model to fill cells in allAllergiesArray table
class UIAllAllergieModel{
    
    var allergieName: String!
    var isEditable: Bool!
    
    init(allergieName: String, isEditable:Bool) {
        self.allergieName = allergieName
        self.isEditable = isEditable
    }
    
    func equalTo(toCompare:UIAllAllergieModel) -> Bool{
        return self.allergieName == toCompare.allergieName
    }
}



class AllergieEditViewController: UIViewController {
    
    @IBOutlet weak var allAllergiesTable: UITableView!
    @IBOutlet weak var gradientView: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    var cdFunctions: CoreDataFunctions!
    
    var allAllergiesArray: [Allergy]! = [Allergy]()
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        self.cdFunctions = CoreDataFunctions(context: context!)
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        doGradientAnimation()

        self.allAllergiesArray = cdFunctions.loadAll(from: "Allergy") as? [Allergy]
        
        allAllergiesTable.dataSource = self
        allAllergiesTable.delegate = self as? UITableViewDelegate
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewAllergyType(_ sender: Any) {
        
        // add alert
        let alterController = UIAlertController(title: "Neue Allergie", message: "Neue Allergie hinzufügen", preferredStyle: .alert)
        
        // add cancel to alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in  }
        alterController.addAction(cancelAction)
        
        // add text field to alert
        alterController.addTextField()
        
        // add submit to alert
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alterController] _ in
            
            // read new Name
            let newAllergieName: String = alterController.textFields![0].text!
            
            if(newAllergieName != ""){
                let currentNameExists: Bool = self.checkIfNameExists( newAllergieName: newAllergieName)
                
                if(!currentNameExists){
                    
                    // if the name is new then add it to the names array
                    let newAllergy = Allergy(context: self.context!)
                    newAllergy.allergyName = newAllergieName
                    newAllergy.isEditable = true
                    newAllergy.isChosen = false
                    
                    self.cdFunctions.saveContext()
                    
                    
                    self.allAllergiesArray = self.cdFunctions.loadAll(from: "Allergy") as? [Allergy]
                    self.allAllergiesTable.reloadData()
                }else{
                    
                    alterController.dismiss(animated: false, completion: nil)
                    
                    let warningAlert = UIAlertController(title: "Warnung", message: "Allergie existiert bereits", preferredStyle: .alert)
                    warningAlert.addAction(UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in })
                    
                    self.present(warningAlert, animated: true, completion: nil)
                }
            }
        }
        
        alterController.addAction(submitAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func checkIfNameExists(newAllergieName: String) -> Bool{
        for model in self.allAllergiesArray{
            
            if (model.allergyName!.uppercased() == newAllergieName.uppercased()){
                return true
            }
        }
        
        return false
    }
    
    func doGradientAnimation(){
        
        self.gradientView.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 5, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.gradientView.frame.height - self.view.frame.height
            self.gradientView.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
}

//Table delegate
extension AllergieEditViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allAllergiesArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = allAllergiesTable.dequeueReusableCell(withIdentifier: "all_allergies_cell") as! AllAllergiesTableViewCell
        
        // eleents will be show reversed: allAllergiesArray!.count - indexPath.row - 1
        if let currentAllergie = allAllergiesArray?[allAllergiesArray!.count - indexPath.row - 1]{
            
            currentCell.model = UIAllAllergieModel(allergieName: currentAllergie.allergyName!, isEditable: currentAllergie.isEditable)
            
            currentCell.buttonRemove.isHidden = !(currentCell.model?.isEditable)!
            currentCell.buttonEdit.isHidden = !(currentCell.model?.isEditable)!

        }
        
        // each cell can be delegated now. it means, each cell can be removed and edited
        currentCell.delegate = self
    
        
        return currentCell
    }
}



//Cell delegate
extension AllergieEditViewController: AllAllergRemoveModelDelegate{
    
    func editModel(currentCell: AllAllergiesTableViewCell) {
        
        var currentAllergy: Allergy?
        
        for allergy in allAllergiesArray{
            if(allergy.allergyName == currentCell.model?.allergieName){
                currentAllergy = allergy
                break
            }
        }
        
        let alterController = UIAlertController(title: "Allergie bearbeiten", message: "", preferredStyle: .alert)

        alterController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = currentCell.allergieName.text
        })
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alterController] _ in
            
            let newAllergieName: String = alterController.textFields![0].text!
            
            if(newAllergieName != ""){
                currentAllergy!.allergyName = newAllergieName
                
                self.cdFunctions.saveContext()
                currentCell.model?.allergieName = newAllergieName
                self.allAllergiesTable.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in}
        
        alterController.addAction(cancelAction)
        alterController.addAction(submitAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func removeModel(currentCell: AllAllergiesTableViewCell) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            
            currentCell.allergieName.center.x += currentCell.buttonRemove.center.x - 80
            currentCell.allergieName.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            currentCell.allergieName.alpha = 1
            
            for (index, allergy) in self.allAllergiesArray!.enumerated(){
                if ( allergy.allergyName == currentCell.model!.allergieName){
                    
                    self.cdFunctions.deleteAllergyFromContext(allergy: allergy)
                    
                    self.allAllergiesArray!.remove(at: index)
                    self.allAllergiesTable.reloadData()
                    break
                }
            }
        })
    }
}
