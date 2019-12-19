//
//  ViewController.swift
//  easyApp
//
//  Created by tbidn001 on 12.12.19.
//  Copyright © 2019 tbidn001. All rights reserved.
//

import UIKit

class UIAllergieModel{
    
    var allergieName: String!
    
    init(allergieName: String) {
        self.allergieName = allergieName
    }
    
    func equalTo(toCompare:UIAllergieModel) -> Bool{
        return self.allergieName == toCompare.allergieName
    }
}

class IndexViewController: UIViewController  {
    
    var pickerData: [String] = [String]()
    var myAllergiesArray: [UIAllergieModel]? = [UIAllergieModel]()

    @IBOutlet weak var myAllergiesTable: UITableView!
    @IBOutlet weak var pickerAllergies: UIPickerView!
    
    @IBAction func addAllergieToMyList(_ sender: UIButton) {
        
        
        let row: Int = pickerAllergies.selectedRow(inComponent: 0)
        
        if (pickerData[row] != "Neu  hinzufügen"){
            myAllergiesArray?.append(UIAllergieModel(allergieName: pickerData[row]))
            pickerData.remove(at: row)
            pickerAllergies.reloadAllComponents()
            
            myAllergiesTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        //Connect data to the picker
        pickerAllergies.delegate = self
        pickerAllergies.dataSource = self
        
        //Picker input data
        pickerData = ["Milch", "Ei", "Soja", "Fisch", "Erdnuss", "Haselnuss", "Sesamsamen", "Krebstiere", "Gluten", "Neu  hinzufügen"]
        
        let middleOfPicker: Int = pickerData.count/2
        pickerAllergies.selectRow(middleOfPicker, inComponent: 0, animated: false)
        
        // 2
        //Connect data to the allergie table
        myAllergiesTable.dataSource = self
        myAllergiesTable.delegate = self as? UITableViewDelegate
        
        myAllergiesArray = [UIAllergieModel]()
        
        //oneCell.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return pickerData.count
    }
}

extension IndexViewController: UIPickerViewDelegate{
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

//Table
extension IndexViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myAllergiesArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCell = myAllergiesTable.dequeueReusableCell(withIdentifier: "allergies_cell") as! MyAllergiesTableViewCell
        
        if let currentAllergie = myAllergiesArray?[indexPath.row]{
            currentCell.model = currentAllergie
        }
        
        currentCell.delegate = self
        
        
        return currentCell
    }
}

extension IndexViewController: RemoveModelDelegate{
    func removeModel(currentCell: MyAllergiesTableViewCell) {
        
        let currentModel = currentCell.model!
        pickerData.append(currentModel.allergieName)
        pickerAllergies.reloadAllComponents()
        
        for (index, models) in myAllergiesArray!.enumerated(){
            if ( models.equalTo(toCompare: currentModel)){
                myAllergiesArray!.remove(at: index)
                myAllergiesTable.reloadData()
            }
        }
    }
}

