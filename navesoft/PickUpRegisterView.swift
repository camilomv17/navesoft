//
//  PickUpRegisterView.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

public class PickUpRegisterView: UIView, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    
    let kPatioPicker = 1
    let kLineaPicker = 2
    let kTamanoPicker = 0
    
    var tableView = UITableView()
    var pickerCellRowHeight = 162.0
    var datePickerIndexPath:NSIndexPath?
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
        tableView = UITableView(frame: self.bounds, style: .Grouped)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = UIColor.whiteColor()
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
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: (self.datePickerIndexPath?.row)!, inSection: 0)], withRowAnimation: .Fade)
        self.datePickerIndexPath = nil
    }
    
    func calculateInexPathForNewPicker(selectedIndexPath:NSIndexPath) ->NSIndexPath
    {
        let newIndexPath:NSIndexPath
        
        if(self.datePickerIsShown() && self.datePickerIndexPath?.row < selectedIndexPath.row){
            newIndexPath = NSIndexPath(forRow: selectedIndexPath.row-1, inSection: 0)
        }
        else{
            newIndexPath = NSIndexPath(forRow: selectedIndexPath.row, inSection: 0)
        }
        
        return newIndexPath
    }
    
    func showNewPickerAtIndex(indexPath:NSIndexPath){
        let  indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        
        
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row)){
            var cell = self.tableView.dequeueReusableCellWithIdentifier("PickerCell")
            if(cell==nil){
                cell = UITableViewCell(style: .Default, reuseIdentifier: "PickerCell")
                patioPicker = UIPickerView(frame: CGRectMake(0,0,self.bounds.size.width,162))
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
            var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
            if(cell==nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
            }
            cell?.accessoryType = .None
            if(indexPath.row == 0){
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.Default;
                textField.autocorrectionType = .No
                textField.returnKeyType = .Done;
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
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
                cell?.detailTextLabel?.text = (dataLines?.objectAtIndex(0) as! NSDictionary).objectForKey("code") as? String
                self.linePicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 3){
                
                cell?.textLabel?.text = "Patio"
                cell?.detailTextLabel?.text = (dataPatios?.objectAtIndex(0) as! NSDictionary).objectForKey("name") as? String
                self.patioPicked = (cell?.detailTextLabel?.text)!
                
            }
            

            return cell!
        }
        
        
       
        
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 4
        if(self.datePickerIsShown()){
            numberOfRows = numberOfRows+1;
        }
        return numberOfRows;
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        
        self.tableView.beginUpdates()
        print(indexPath.row)
        
        if(self.datePickerIsShown() && self.datePickerIndexPath!.row - 1 == indexPath.row ){
            self.hideExistingPicker()
        }
        else{
            
            if(self.datePickerIsShown()){
                self.hideExistingPicker()
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
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
                self.datePickerIndexPath = NSIndexPath(forRow: newPickerIndexPath.row + 1, inSection: 0)
            }
            else{
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                cell?.viewWithTag(kTextFieldChildTag)?.becomeFirstResponder()
            }
           
        }
    
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        self.tableView.endUpdates()
        
        
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = 45.0
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row)){
            rowHeight = self.pickerCellRowHeight
        }
        
        return CGFloat(rowHeight);
        
        
        
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Datos para recogida de contenedor"
    }
    
    
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentPicker == kPatioPicker){
            let dict = dataPatios?.objectAtIndex(row) as! NSDictionary
            return dict.objectForKey("name") as? String
            
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.objectAtIndex(row) as! NSDictionary
            return dict.objectForKey("code") as? String
        }
        else{
            return dataTamaños?.objectAtIndex(row) as? String
        }
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(currentPicker == kPatioPicker){
            let dict = dataPatios?.objectAtIndex(row) as! NSDictionary
            self.patioPicked = (dict.objectForKey("name") as? String)!
            selectedPatio = row;
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
            cell?.detailTextLabel?.text = self.patioPicked
            print(self.patioPicked)
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.objectAtIndex(row) as! NSDictionary
            self.linePicked = (dict.objectForKey("code") as? String)!
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
            cell?.detailTextLabel?.text = self.linePicked
            print(self.linePicked)
        }
        else{
            self.tamanoPicked = (dataTamaños?.objectAtIndex(row) as? String)!
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            cell?.detailTextLabel?.text = self.tamanoPicked
            print(self.tamanoPicked)

            
        }
    }
    
    
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
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
        
        let booking = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(kTextFieldChildTag) as! UITextField).text
        
        if(booking == ""){
            return nil;
        }
        else{
            info.setObject(booking!, forKey: "Booking")
        }
        
        let tamano = tamanoPicked
        
        if(tamano == ""){
            return nil
        }
        else{
            info.setObject(tamano, forKey: "Tamano")
        }
        
        let linea = self.linePicked
        
        if(linea == ""){
            return nil
        }
        else{
            info.setObject(linea, forKey: "Linea")
        }
        
        let patio = self.patioPicked
        
        if(patio == ""){
            return nil
        }
        else{
            info.setObject(patio, forKey: "Patio")
        }
        
        let dict = dataPatios?.objectAtIndex(selectedPatio) as! NSDictionary
        let patioCode = (dict.objectForKey("code") as? String)!
        info.setObject(patioCode, forKey: "patioCode");
        
        return info
    }

    
    

    
    
    
}
