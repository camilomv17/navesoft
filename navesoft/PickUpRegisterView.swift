//
//  PickUpRegisterView.swift
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


open class PickUpRegisterView: UIView, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    
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
    
    var dataTamaños:NSArray?
    init(frame: CGRect,lines:NSArray,patios:NSArray) {
        super.init(frame: frame)
        currentPicker = 0
        selectedPatio = 0;
        self.dataLines = lines;
        self.dataPatios = patios
        tableView = UITableView(frame: self.bounds, style: .grouped)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = UIColor.white
        self.addSubview(tableView)
        initialTvHeight = tableView.frame.size.height
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)
        
        dataTamaños = ["20 (un contenedor)","20 (dos contenedores)","40"]
        
    }
    
    
    
    

    required public init?(coder aDecoder: NSCoder) {
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
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
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
                
                cell?.textLabel!.text = "No. de Booking"
                
            }
            else if(indexPath.row == 1){
                cell?.textLabel?.text = "Tamaño"
                cell?.detailTextLabel?.text = dataTamaños![0] as? String
                self.tamanoPicked = (cell?.detailTextLabel?.text)!
            }
            else if(indexPath.row == 2){
                cell?.textLabel?.text = "Linea Naviera"
                cell?.detailTextLabel?.text = (dataLines?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                self.linePicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 3){
                
                cell?.textLabel?.text = "Patio"
                cell?.detailTextLabel?.text = (dataPatios?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                self.patioPicked = (cell?.detailTextLabel?.text)!
                
            }
            

            return cell!
        }
        
        
       
        
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 4
        if(self.datePickerIsShown()){
            numberOfRows = numberOfRows+1;
        }
        return numberOfRows;
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        self.tableView.beginUpdates()
        print(indexPath.row)
        
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
            if(indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 1 ){
                self.endEditing(true)
                let newPickerIndexPath = self.calculateInexPathForNewPicker(indexPath)
                self.showNewPickerAtIndex(newPickerIndexPath)
                
                if(indexPath.row == 1){
                    currentPicker = kTamanoPicker
                }
                
                else if(indexPath.row == 2){
                    currentPicker = kLineaPicker
                }
                else{
                    currentPicker = kPatioPicker
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
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = 45.0
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row)){
            rowHeight = self.pickerCellRowHeight
        }
        
        return CGFloat(rowHeight);
        
        
        
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Datos para recogida de contenedor"
    }
    
    
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentPicker == kPatioPicker){
            return (dataPatios?.count)!
        }
        else if(currentPicker == kLineaPicker){
            return (dataLines?.count)!
        }
        else
        {
            return (dataTamaños?.count)!
        }
        
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            print(self.tamanoPicked)

            
        }
    }
    
    
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func fetchInfo() -> NSDictionary?{
        self.endEditing(true)
        if(self.datePickerIsShown()){
            tableView.beginUpdates()
            self.hideExistingPicker()
            tableView.endUpdates()
        }
        let info = NSMutableDictionary()
        
        let booking = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.viewWithTag(kTextFieldChildTag) as! UITextField).text
        
        if(booking == ""){
            return nil;
        }
        else{
            info.setObject(booking!, forKey: "Booking" as NSCopying)
        }
        
        let tamano = tamanoPicked
        
        if(tamano == ""){
            return nil
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
