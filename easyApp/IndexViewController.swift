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
    @IBOutlet weak var gradientVideo: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    
   override func viewDidLoad() {
         super.viewDidLoad()
    
    context = appDelegate?.persistentContainer.viewContext
    
    //deleteAllFromTable()
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
    
            
           //Connect data to the allergie table
           myAllergiesTable.dataSource = self
           myAllergiesTable.delegate = self as? UITableViewDelegate
    }
    
    func doGradientAnimation(){
        
        print("in animation")
        self.gradientVideo.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 10, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let x = -self.gradientVideo.frame.width + self.view.frame.width
            self.gradientVideo.transform = CGAffineTransform(translationX: x, y: 0)
        })
    }
    
    override func viewWillAppear(_ animated: Bool){
        print("*** IndexViewController")
        doGradientAnimation()

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
        
        /*
        pickerAllergiesArray?.sort(by: {UIContentSizeCategory(rawValue: $0.allergyName!) > UIContentSizeCategory(rawValue: $1.allergyName!)})
        */
        
        allergiesPicker.reloadAllComponents()
        myAllergiesTable.reloadData()
      
    }
    
    /*
    func selectMiddleOfPicker(){
        let middleOfPicker: Int = allAllergies.count/2
        allergiesPicker.selectRow(middleOfPicker, inComponent: 0, animated: false)
    }
    */
    
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
        
        var output:NSManagedObject?
        
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
    
    // DB

    func saveDataInDB(allergyName: String){
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
        
            let request: NSFetchRequest<Allergy> = Allergy.fetchRequest()
            
            do{
                results = try context!.fetch(request)
            }catch{
                
            }
        
        
        return results
    }

    func deleteAllFromTable() {
            //Make request
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Allergy")
            
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
        
        print("deleted successfuly: all elements")
    }

    // edit one element from DB
    func editElementInDB() {
            
            do {
                try context!.save()
                
            } catch{
                print(error)
            }
        
        
        print("changed successfully")
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerAllergiesArray![row].allergyName!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
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
        
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            print("animation")
            
            currentCell.allergieName.center.x += currentCell.removeButton.center.x - 80
            currentCell.allergieName.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            currentCell.allergieName.alpha = 1
            
            let currentModel = currentCell.model!
                
                
            for (index, model) in self.myAllergyModelsArray!.enumerated(){
                    if(model.equalTo(toCompare: currentModel)){
                        self.myAllergyModelsArray!.remove(at: index)
                        self.myAllergiesTable.reloadData()
                        break
                    }
                }
                
            for allergy in self.allAllergies{
                    if(allergy.allergyName == currentModel.allergyName){
                        allergy.isChosen = false
                        
                        self.editElementInDB()
                        
                        self.pickerAllergiesArray!.append(allergy)
                        self.allergiesPicker.reloadAllComponents()
                                               
                        self.addButton.isEnabled = true
                    }
                }
        })
    }
}
