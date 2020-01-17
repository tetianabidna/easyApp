//
//  ViewController.swift
//  easyApp
//
//  Created by tbidn001 on 12.12.19.
//  Copyright © 2019 tbidn001. All rights reserved.
//

import UIKit
import CoreData

class UIMyAllergyModel{
    
    var allergyName: String!

    init(allergyName: String) {
        self.allergyName = allergyName
    }
    
    func equalTo(toCompare:UIMyAllergyModel) -> Bool{
        return self.allergyName == toCompare.allergyName
    }
}

class IndexViewController: UIViewController  {
    
    var allAllergies: [Allergy] = [Allergy] ()
    
    var myAllergyModelsArray: [UIMyAllergyModel]?
    var pickerAllergiesArray: [Allergy]?

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var myAllergiesTable: UITableView!
    @IBOutlet weak var allergiesPicker: UIPickerView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
   override func viewDidLoad() {
         super.viewDidLoad()
    //deleteAllFromTable()
         print("didLoad")
    
    context = appDelegate?.persistentContainer.viewContext
    
    self.allAllergies = loadNamesFromDB()
    
    if (allAllergies.count == 0){
             print("allergyNames was empty")
             
             let allergyNames = ["Milch", "Ei", "Soja", "Krebstiere", "Gluten"]
             for allergy in allergyNames{
                 saveDataInDB(allergyName: allergy)
             }
         }
    
            //Connect data to the allergie picker
            allergiesPicker.delegate = self
            allergiesPicker.dataSource = self
    
            selectMiddleOfPicker()
           
           //Connect data to the allergie table
           myAllergiesTable.dataSource = self
           myAllergiesTable.delegate = self as? UITableViewDelegate
     }
    
    override func viewWillAppear(_ animated: Bool){
        print("didAppear")
        
        pickerAllergiesArray = [Allergy]()
        myAllergyModelsArray = [UIMyAllergyModel]()
        
        self.allAllergies = loadNamesFromDB()
        
        for allergy in allAllergies{
            if(allergy.isChosen){
                myAllergyModelsArray!.append(UIMyAllergyModel(allergyName: allergy.allergyName!))
            }else{
                pickerAllergiesArray!.append(allergy)
            }
        }
        
        for allergy in pickerAllergiesArray!{
            print("picker: \(allergy.toString())")
        }
        
        for model in myAllergyModelsArray!{
            print("table: \(model.allergyName)")
        }
        
        selectMiddleOfPicker()
              
        allergiesPicker.reloadAllComponents()
        myAllergiesTable.reloadData()
    }
    
    func selectMiddleOfPicker(){
        let middleOfPicker: Int = allAllergies.count/2
        allergiesPicker.selectRow(middleOfPicker, inComponent: 0, animated: false)
    }
    
    @IBAction func addAllergieToMyList(_ sender: UIButton) {
        print("add")
        
        
        if( pickerAllergiesArray!.count > 0){
            
            
            let selectedRow = allergiesPicker.selectedRow(inComponent: 0)
            
            let currentModel = pickerAllergiesArray![selectedRow]
            
            // change DB
            currentModel.isChosen = true
            editElementInDB()
            
            // update picker
            pickerAllergiesArray!.remove(at: selectedRow)
            allergiesPicker.reloadAllComponents()
            
            // update table
            myAllergyModelsArray!.append(UIMyAllergyModel(allergyName: currentModel.allergyName!))
            myAllergiesTable.reloadData()
            
            if(pickerAllergiesArray!.count == 0){
                addButton.isEnabled = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    // search one element in DB
    func searchForElementInDB(allergyName: String) -> NSManagedObject{
        
        var output:NSManagedObject? = nil
        
       // if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
       // let context = appDelegate?.persistentContainer.viewContext
            
            //Make request
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
            
            if let allergies = try! context!.fetch(request) as? [Allergy] {
                allergies.forEach({
                    if($0.allergyName == allergyName){
                        
                        output = $0
                    }
                })
            }
    //    }
        
        return output!
    }
    
    // DB

    func saveDataInDB(allergyName: String){
        //identify context
        
        /*
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        */
        
        let newAllergy = Allergy(context: context!)
        newAllergy.allergyName = allergyName
        newAllergy.isEditable = false
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
        
       // if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
       //     let context = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Allergy> = Allergy.fetchRequest()
            
            do{
                results = try context!.fetch(request)
            }catch{
                
            }
            
     //   }
        
        
        return results
    }

    func deleteAllFromTable() {
      //  if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
       //     let context = appDelegate.persistentContainer.viewContext
            
            let entityName = "Allergy"
            
            //Make request
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            do{
                let results = try context!.fetch(request)
                
                for r in results{
                    if let result = r as? NSManagedObject{
                        context!.delete(result)
                    }
                }
            }catch{
                print(error)
            }
      //  }
        
        print("deleted successfuly: all elements")
    }

    // edit one element from DB
    func editElementInDB() {
        
     //   if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
     //       let context = appDelegate.persistentContainer.viewContext
            
            do {
                try context!.save()
                
            } catch{
                print(error)
            }
     //   }
        
        
        
        print("changed successful")
    }
}





//Picked
extension IndexViewController: UIPickerViewDataSource{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerAllergiesArray?.count ?? 0
    }
}

extension IndexViewController: UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerAllergiesArray![row].allergyName
    }
}

//Table
extension IndexViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myAllergyModelsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = myAllergiesTable.dequeueReusableCell(withIdentifier: "allergies_cell") as! MyAllergiesTableViewCell
        
        // show elements reverse: myAllergiesArray!.count - indexPath.row - 1
        let currentAllergie = myAllergyModelsArray![myAllergyModelsArray!.count - indexPath.row - 1]
        currentCell.model = currentAllergie
        
        currentCell.delegate = self
        
        return currentCell
    }
}

extension IndexViewController: RemoveModelDelegate{
    func removeModel(currentCell: MyAllergiesTableViewCell) {
        
        let currentModel = currentCell.model!
        
        
        for (index, model) in myAllergyModelsArray!.enumerated(){
            if(model.equalTo(toCompare: currentModel)){
                myAllergyModelsArray!.remove(at: index)
                myAllergiesTable.reloadData()
                break
            }
        }
        
        for allergy in allAllergies{
            if(allergy.allergyName == currentModel.allergyName){
                allergy.isChosen = false
                
                editElementInDB()
                
                pickerAllergiesArray!.append(allergy)
                allergiesPicker.reloadAllComponents()
                selectMiddleOfPicker()
                
                addButton.isEnabled = true
            }
        }
    }
}
