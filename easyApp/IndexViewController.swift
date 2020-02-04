//
//  ViewController.swift
//  easyApp
//
//  Created by tbidn001 on 12.12.19.
//  Copyright © 2019 tbidn001. All rights reserved.
//

import UIKit
import CoreData

//The model that is loaded in the myAllergy table
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
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext?
    var cdFunctions: CoreDataFunctions?
    
    var allAllergies: [Allergy] = [Allergy] ()
    var myAllergyModelsArray: [UIMyAllergyModel]?
    var pickerAllergiesArray: [Allergy]?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var myAllergiesTable: UITableView!
    @IBOutlet weak var allergiesPicker: UIPickerView!
    @IBOutlet weak var gradientVideo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate?.persistentContainer.viewContext
        self.cdFunctions = CoreDataFunctions(context: context!)
        
        //self.cdFunctions!.deleteAll(from: "Allergy") // to comment
        self.allAllergies = cdFunctions?.loadAll(from: "Allergy") as! [Allergy]
        
        //Is activated when the app is opened for the first time
        if (allAllergies.count == 0){
                       
            let allergyNames = ["Milch", "Ei", "Soja", "Krebstiere", "Gluten", "Schalenfrüchte", "Laktose"]
            for allergyName in allergyNames{
                
                let newAllergy = Allergy(context: context!)
                newAllergy.allergyName = allergyName
                newAllergy.isEditable = false
                newAllergy.isChosen = false
            }
            
            cdFunctions!.saveContext()
        }
        
        //Connect data to the allergy picker
        allergiesPicker.delegate = self
        allergiesPicker.dataSource = self
        
        
        //Connect data to the allergy table
        myAllergiesTable.dataSource = self
        myAllergiesTable.delegate = self as? UITableViewDelegate
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        
        doGradientAnimation()
        updateInformation()
    }
    
    func updateInformation(){
        
        //Picker and table are first emptied
        pickerAllergiesArray = [Allergy]()
        myAllergyModelsArray = [UIMyAllergyModel]()
        
        //Updated data is fetched from CD
        self.allAllergies = cdFunctions?.loadAll(from: "Allergy") as! [Allergy]

        //Picker and table are updated with the new data
        for allergy in allAllergies{
            
            if(allergy.isChosen){
                
                myAllergyModelsArray!.append(UIMyAllergyModel(allergyName: allergy.allergyName!))
            }else{
                
                pickerAllergiesArray!.append(allergy)
            }
        }
        
        allergiesPicker.reloadAllComponents()
        myAllergiesTable.reloadData()
    }
    
    @IBAction func addAllergieToMyList(_ sender: UIButton) {
        
        if( pickerAllergiesArray!.count > 0){
            
            let selectedRow = allergiesPicker.selectedRow(inComponent: 0)
            
            let currentAllergy = pickerAllergiesArray![selectedRow]
            
            // change CD
            currentAllergy.isChosen = true
            cdFunctions?.saveContext()
            
            // update picker
            pickerAllergiesArray!.remove(at: selectedRow)
            allergiesPicker.reloadAllComponents()
            
            // update table
            myAllergyModelsArray!.append(UIMyAllergyModel(allergyName: currentAllergy.allergyName!))
            myAllergiesTable.reloadData()
            
            if(pickerAllergiesArray!.count == 0){
                addButton.isEnabled = false
            }
        }
    }
    
    func doGradientAnimation(){
        
        self.gradientVideo.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 5, delay:0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let y = self.gradientVideo.frame.height - self.view.frame.height
            self.gradientVideo.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }
}

//Picker data source and delegate management
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Futura", size: 25)
        
        // where data is an Array of String
        label.text = pickerAllergiesArray![row].allergyName!
        
        
        return label
    }
}

//Table data source and delegate management
extension IndexViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myAllergyModelsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = myAllergiesTable.dequeueReusableCell(withIdentifier: "allergies_cell") as! MyAllergiesTableViewCell
        
        // show elements in reverse
        let currentAllergie = myAllergyModelsArray![myAllergyModelsArray!.count - indexPath.row - 1]
        currentCell.model = currentAllergie
        
        currentCell.delegate = self
        
        return currentCell
    }
}

extension IndexViewController: RemoveModelDelegate{
    
    //After an allergy is deleted from the table it is sent to the picker
    func removeModel(currentCell: MyAllergiesTableViewCell) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            
            currentCell.allergieName.center.x += currentCell.removeButton.center.x - 80
            currentCell.allergieName.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            currentCell.allergieName.center.x -= currentCell.removeButton.center.x - 80
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
                    self.cdFunctions?.saveContext()
                    
                    self.pickerAllergiesArray!.append(allergy)
                    self.allergiesPicker.reloadAllComponents()
                    
                    self.addButton.isEnabled = true
                }
            }
        })
    }
}
