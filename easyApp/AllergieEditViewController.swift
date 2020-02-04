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
    
    var allAllergiesArray: [Allergy]! = [Allergy]()
    
    @IBOutlet weak var allAllergiesTable: UITableView!
    @IBOutlet weak var gradientView: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        doGradientAnimation()
        
        print("--- AllergieEditViewController")
        
        
        context = appDelegate?.persistentContainer.viewContext

        
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        doGradientAnimation()

        
        self.allAllergiesArray = loadNamesFromDB()
        
        allAllergiesTable.dataSource = self
        allAllergiesTable.delegate = self as? UITableViewDelegate
    }
    
    func doGradientAnimation(){
        
        print("in animation")
        self.gradientView.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 8, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.gradientView.frame.height - self.view.frame.height
            self.gradientView.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewAllergyType(_ sender: Any) {
        
        // add alert
        let alterController = UIAlertController(title: "New Allergy", message: "Add new allergy", preferredStyle: .alert)
        
        // add cancel to alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
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
                    self.saveDataInDB(allergyName: newAllergieName)
                    
                    self.allAllergiesArray = self.loadNamesFromDB()
                    self.allAllergiesTable.reloadData()
                    
                    print("New allergy was added")
                }else{
                    
                    alterController.dismiss(animated: false, completion: nil)
                    print("Warning")
                    
                    let warningAlert = UIAlertController(title: "Warning", message: "Allergy exists already", preferredStyle: .alert)
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
    
       // DB
       // save one element in DB
       func saveDataInDB(allergyName: String){
        
           let newAllergy = Allergy(context: context!)
           newAllergy.allergyName = allergyName
           newAllergy.isEditable = true
           newAllergy.isChosen = false

           do {
               try context!.save()
               print("saved successfuly: \(allergyName)")
           } catch{
               print(error)
           }
       }
       
       
       func loadNamesFromDB() -> [Allergy] {
           print("load")
           var results: [Allergy] = [Allergy]()
           
               let request: NSFetchRequest<Allergy> = Allergy.fetchRequest()
               
               do{
                   results = try context!.fetch(request)
               }catch{
                   
               }
           
           
           return results
       }
       
       // edit one element from DB
       func editElementInDB( ) {
               do {
                   try context!.save()
                   
               } catch{
                   print(error)
               }
               
           
           print("edited successfuly")
       }
       
       // delete one element from DB
       func deleteElementFromDB( allergy: Allergy) {
               context!.delete(allergy)
           
           print("deleted successfuly: \(allergy.allergyName!)")
       }
       
       
       // search one element in DB
       func searchForElementInDB(allergyName: String) -> NSManagedObject{
           
           var output:NSManagedObject? = nil
        
               //Make request
               let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
               
               if let allergies = try! context!.fetch(request) as? [Allergy] {
                   allergies.forEach({
                       if($0.allergyName == allergyName){
                           
                           output = $0
                       }
                   })
               }
           
           return output!
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
            
            currentCell.butRemove.isHidden = !(currentCell.model?.isEditable)!
            currentCell.butEdit.isHidden = !(currentCell.model?.isEditable)!

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
        
        let alterController = UIAlertController(title: "Edit allergy", message: "", preferredStyle: .alert)

        alterController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = currentCell.allergieName.text
        })
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alterController] _ in
            
            let newAllergieName: String = alterController.textFields![0].text!
            
            if(newAllergieName != ""){
                currentAllergy!.allergyName = newAllergieName
                
                self.editElementInDB()
                
                currentCell.model?.allergieName = newAllergieName
                self.allAllergiesTable.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        
        alterController.addAction(cancelAction)
        alterController.addAction(submitAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func removeModel(currentCell: AllAllergiesTableViewCell) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            print("animation")
            
            currentCell.allergieName.center.x += currentCell.butRemove.center.x - 80
            currentCell.allergieName.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            currentCell.allergieName.alpha = 1
            
            for (index, model) in self.allAllergiesArray!.enumerated(){
                if ( model.allergyName == currentCell.model!.allergieName){
                    
                    self.deleteElementFromDB(allergy: model)
                    
                    self.allAllergiesArray!.remove(at: index)
                    self.allAllergiesTable.reloadData()
                    break
                }
            }
        })
    }
}
