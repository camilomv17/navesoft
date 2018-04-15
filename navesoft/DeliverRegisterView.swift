//
//  DeliverRegisterView.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class DeliverRegisterView: UIView,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    let kPatioPicker = 1
    let kLineaPicker = 2
    let kTamanoPicker = 0
    
    var tableView = UITableView()
    var pickerCellRowHeight = 162.0
    var datePickerIndexPath:IndexPath?
    var patioPicker:UIPickerView?
    var initialTvHeight = CGFloat(0.0)
    let kPatioPickerTag = 1
    let kTextFieldChildTag = 10
    
    var dataLines:NSArray?
    var dataPatios:NSArray?
    var currentPicker = 0
    var patioPicked = ""
    var linePicked = ""
    var tamanoPicked = ""
    var selectedPatio = 0;
    var extraContainer = false
    
    var dataTamaños:NSArray?
     init(frame: CGRect,lines:NSArray,patios:NSArray) {
        super.init(frame: frame)
        currentPicker = 0;
        selectedPatio = 0;
        self.dataLines = lines;
        self.dataPatios = patios
        tableView = UITableView(frame: self.bounds, style: .grouped)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = UIColor.white
        self.addSubview(tableView)
        initialTvHeight = tableView.frame.size.height
        dataTamaños = ["20 (un contenedor)","20 (dos contenedores)","40"]

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func datePickerIsShown() ->Bool{
        return self.datePickerIndexPath != nil
    }
    
    func hideExistingPicker(){
        self.tableView.deleteRows(at: [IndexPath(row: (self.datePickerIndexPath?.row)!, section: 0)], with: .fade)
        self.datePickerIndexPath = nil
    }
    
    func calculateInexPathForNewPicker(_ selectedIndexPath:IndexPath) ->IndexPath
    {
        let newIndexPath:IndexPath
        
        if(self.datePickerIsShown() && self.datePickerIndexPath?.row < selectedIndexPath.row){
            newIndexPath = IndexPath(row: selectedIndexPath.row-1, section: 0)
        }
        else{
            newIndexPath = IndexPath(row: selectedIndexPath.row, section: 0)
        }
        
        return newIndexPath
    }
    
    func showNewPickerAtIndex(_ indexPath:IndexPath){
        let  indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]
        
        self.tableView.insertRows(at: indexPaths, with: .fade)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(indexPath.row)
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row)){
            var cell = self.tableView.dequeueReusableCell(withIdentifier: "PickerCell")
            if(cell==nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: "PickerCell")
                patioPicker = UIPickerView(frame: CGRect(x: 0,y: 0,width: self.bounds.size.width,height: 162))
                patioPicker?.dataSource = self
                patioPicker?.delegate = self
                patioPicker?.tag = kPatioPickerTag
                cell?.contentView.addSubview(patioPicker!)
            }
            else{
                patioPicker = cell?.contentView.viewWithTag(kPatioPickerTag) as? UIPickerView
            }
            
            
            
            return cell!
        }
        else{
            var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
            if(cell==nil){
                cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
            }
            cell?.accessoryType = .none
            cell?.tag = indexPath.row
            if(indexPath.row == 0){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.default;
                textField.autocorrectionType = .no
                textField.returnKeyType = .done;
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.delegate = self
                textField.tag = kTextFieldChildTag
                
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "No. Contenedor"
                
            }
            var extraCell = 0
            if(extraContainer){
                extraCell = 1
                if(indexPath.row == 1){
                    let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                    textField.adjustsFontSizeToFitWidth = true
                    textField.textColor = UIColor.black
                    textField.placeholder = "";
                    textField.keyboardType = UIKeyboardType.default;
                    textField.autocorrectionType = .no
                    textField.returnKeyType = .done;
                    textField.backgroundColor = UIColor.white
                    textField.textAlignment = .left
                    textField.delegate = self
                    textField.tag = kTextFieldChildTag
                    
                    cell?.contentView.addSubview(textField)
                    
                    cell?.textLabel!.text = "No. Contenedor 2"
                    
                }
            }
            
            
            
                
            if(indexPath.row == 1+extraCell){
                cell?.textLabel?.text = "Tamaño"
                cell?.detailTextLabel?.text = dataTamaños![0] as? String
                self.tamanoPicked = (cell?.detailTextLabel?.text)!
            }
            else if(indexPath.row == 2+extraCell){
                cell?.textLabel?.text = "Linea Naviera"
                cell?.detailTextLabel?.text = (dataLines?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                self.linePicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 3+extraCell){
                
                cell?.textLabel?.text = "Patio"
                cell?.detailTextLabel?.text = (dataPatios?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                self.patioPicked = (cell?.detailTextLabel?.text)!
                
            }
            return cell!
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 4
        if(self.datePickerIsShown()){
            numberOfRows = numberOfRows+1;
        }
        if(self.extraContainer){
            numberOfRows = numberOfRows+1;
        }
        return numberOfRows;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.tableView.beginUpdates()
        
        if(self.datePickerIsShown() && self.datePickerIndexPath!.row - 1 == indexPath.row ){
            self.hideExistingPicker()
        }
        else{
            
            if(self.datePickerIsShown()){
                self.hideExistingPicker()
                
                tableView.deselectRow(at: indexPath, animated: true)
                
                self.tableView.endUpdates()
                return
            }
            var extraCell = 0
            if(extraContainer){
                extraCell = 1
                
            }

            if(indexPath.row == 1+extraCell || indexPath.row == 2+extraCell || indexPath.row == 3+extraCell){
                self.endEditing(true)
                let newPickerIndexPath = self.calculateInexPathForNewPicker(indexPath)
                self.showNewPickerAtIndex(newPickerIndexPath)
                
                if(indexPath.row == 2+extraCell){
                    currentPicker = kLineaPicker
                }
                else if(indexPath.row == 3+extraCell){
                    currentPicker = kPatioPicker
                }
                else{
                    currentPicker = kTamanoPicker
                }
                self.patioPicker?.reloadAllComponents()
                
                self.datePickerIndexPath = IndexPath(row: newPickerIndexPath.row + 1, section: 0)
            }
            else{
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.viewWithTag(kTextFieldChildTag)?.becomeFirstResponder()
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.endUpdates()
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = 45.0
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row)){
            rowHeight = self.pickerCellRowHeight
        }
        
        return CGFloat(rowHeight);
        
        
        
    }
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Datos para devolución de contenedor"
    }
    
    
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentPicker == kPatioPicker){
            return (dataPatios?.count)!
        }
        else if(currentPicker == kLineaPicker){
            return (dataLines?.count)!
        }
        else {
            return (dataTamaños?.count)!
        }
        
    }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentPicker == kPatioPicker){
            let dict = dataPatios?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
            
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            return dict.object(forKey: "code") as? String
        }
        else{
            return dataTamaños?.object(at: row) as? String
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(currentPicker == kPatioPicker){
            let dict = dataPatios?.object(at: row) as! NSDictionary
            self.patioPicked = (dict.object(forKey: "name") as? String)!
            selectedPatio = row;
            let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))
            cell?.detailTextLabel?.text = self.patioPicked
            print(self.patioPicked)
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            self.linePicked = (dict.object(forKey: "code") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))
            cell?.detailTextLabel?.text = self.linePicked
            print(self.linePicked)
        }
        else{
            self.tamanoPicked = (dataTamaños?.object(at: row) as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
            cell?.detailTextLabel?.text = self.tamanoPicked
            
            if(row == 1){
                if(!extraContainer){
                extraContainer = true
                self.datePickerIndexPath = IndexPath(row: 3, section: 0);
                self.tableView.beginUpdates();
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .right)
                
                self.tableView.endUpdates()
                }
               
            }
            else{
                if(extraContainer){
                    extraContainer = false
                    self.datePickerIndexPath = IndexPath(row: 2, section: 0);
                    self.tableView.beginUpdates();
                    self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .right)
                    
                    self.tableView.endUpdates()

                }
            }
            
            
            
            print(self.tamanoPicked)
        }
    }

    
    func fetchInfo() -> NSDictionary?{
        if(self.datePickerIsShown()){
            tableView.beginUpdates()
            self.hideExistingPicker()
            tableView.endUpdates()
        }
        let info = NSMutableDictionary()
        
        let contenedor = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.viewWithTag(kTextFieldChildTag) as! UITextField).text
        
        if(contenedor == ""){
            return nil;
        }
        else{
            info.setObject(contenedor!, forKey: "Contenedor" as NSCopying)
        }
        
        if(extraContainer){
            let contenedor2 = (self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.viewWithTag(kTextFieldChildTag) as! UITextField).text
            if(contenedor2 == ""){
                return nil;
            }
            else{
                info.setObject(contenedor2!, forKey: "Contenedor2" as NSCopying)
            }
        }
        
        let tamano = self.tamanoPicked
        
        if(tamano == ""){
            return nil;
        }
        else{
            info.setObject(tamano, forKey: "Tamano" as NSCopying)
        }
        
        
        let linea = self.linePicked
        
        if(linea == ""){
            return nil
        }
        else{
            info.setObject(linea, forKey: "Linea" as NSCopying)
        }
        
        let patio = self.patioPicked
        
        if(patio == ""){
            return nil
        }
        else{
            info.setObject(patio, forKey: "Patio" as NSCopying)
        }
        let dict = dataPatios?.object(at: selectedPatio) as! NSDictionary
        let patioCode = (dict.object(forKey: "code") as? String)!
        info.setObject(patioCode, forKey: "patioCode" as NSCopying);
        return info
    }
    

  



    
}
