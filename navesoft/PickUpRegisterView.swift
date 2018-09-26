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
    let kTipoPicker = 3
    let kCiudadRetiroPicker = 4;
    let kCiudadDestinoPicker = 5
    let kPatioDestinoPicker = 6;
    
    let kPatioRetiroCellTag = 11
    let kPatioDestinoCellTag = 12

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
    var tipoPicked = "";
    var ciudadRetiroPicked = "";
    var ciudadDestinoPicked = "";
    var patioDestinoPicked = "";
    var selectedPatio = 0;
    var selectedPatioDestino = 0;
    
    var dataTamaños:NSArray?
    var dataTipos:NSArray?
    var dataCiudades:NSArray?
    var dataPatiosRetiro:NSMutableArray?
    var dataPatiosDestino:NSMutableArray?
    
    init(frame: CGRect,lines:NSArray,patios:NSArray, ciudades:NSArray) {
        super.init(frame: frame)
        currentPicker = 0
        selectedPatio = 0;
        selectedPatioDestino = 0;
        self.dataLines = lines;
        self.dataPatios = patios;
        self.dataCiudades = ciudades;
        tableView = UITableView(frame: self.bounds, style: .grouped)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = UIColor.white
        self.addSubview(tableView)
        initialTvHeight = tableView.frame.size.height
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)
        
        dataTamaños = ["20 (un contenedor)","20 (dos contenedores)","40"]
        dataTipos = ["EXPO","REPO"];
        
        let firstCity = (dataCiudades?.object(at: 0) as! NSDictionary).value(forKey: "code") as! String;
        filterDataPatios(codigoCiudad: firstCity, picker: kCiudadDestinoPicker, updating: false)
        filterDataPatios(codigoCiudad: firstCity, picker: kCiudadRetiroPicker, updating: false)
        
    }
    
    
    
    

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func filterDataPatios(codigoCiudad:String, picker: Int, updating: Bool){
        if(picker == kCiudadRetiroPicker){
            dataPatiosRetiro = NSMutableArray();
            
            for patio in dataPatios! {
                let temp = patio as! NSDictionary
                if (temp.object(forKey: "city") as! String == codigoCiudad ){
                    dataPatiosRetiro?.add(temp);
                }
            }
            if(updating){
            let index = IndexPath(item: 6, section: 0)
            let cell = self.tableView.cellForRow(at: index) as! UITableViewCell
            cell.detailTextLabel?.text = (dataPatiosRetiro?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String;
                selectedPatio = 0
            }
        }
        else{
            dataPatiosDestino = NSMutableArray();
            
            for patio in dataPatios! {
                let temp = patio as! NSDictionary
                if (temp.object(forKey: "city") as! String == codigoCiudad ){
                    dataPatiosDestino?.add(temp);
                }
            }
            if(updating){
            let index = IndexPath(item: 8, section: 0)
            let cell = self.tableView.cellForRow(at: index) as! UITableViewCell
            cell.detailTextLabel?.text = (dataPatiosDestino?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String;
                selectedPatioDestino = 0;
            }
           
        }
       
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
                cell?.textLabel?.text = "Tipo"
                cell?.detailTextLabel?.text = dataTipos![0] as? String
                self.tipoPicked = (cell?.detailTextLabel?.text)!
            }
                
            else if(indexPath.row == 2){
                cell?.textLabel?.text = "Tamaño"
                cell?.detailTextLabel?.text = dataTamaños![0] as? String
                self.tamanoPicked = (cell?.detailTextLabel?.text)!
            }
            else if(indexPath.row == 3){
                cell?.textLabel?.text = "Linea Naviera"
                cell?.detailTextLabel?.text = (dataLines?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                self.linePicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 4){
                
                cell?.textLabel?.text = "Ciudad Retiro"
                cell?.detailTextLabel?.text = (dataCiudades?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                self.ciudadRetiroPicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 5){
                
                cell?.textLabel?.text = "Patio"
                cell?.detailTextLabel?.text = (dataPatiosRetiro?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                self.patioPicked = (cell?.detailTextLabel?.text)!
                cell?.tag = kPatioRetiroCellTag
                
            }
            else if(indexPath.row == 6){
                
                cell?.textLabel?.text = "Ciudad Destino"
                cell?.detailTextLabel?.text = (dataCiudades?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                self.ciudadDestinoPicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 7){
                
                cell?.textLabel?.text = "Patio Destino"
                  cell?.detailTextLabel?.text = (dataPatiosDestino?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                 self.patioDestinoPicked = (cell?.detailTextLabel?.text)!
                cell?.tag = kPatioDestinoPicker;
                
            }
            

            return cell!
        }
        
        
       
        
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 8
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
            if(indexPath.row > 0  ){
                self.endEditing(true)
                let newPickerIndexPath = self.calculateInexPathForNewPicker(indexPath)
                self.showNewPickerAtIndex(newPickerIndexPath)
                
                
                if(indexPath.row == 1){
                    currentPicker = kTipoPicker
                }
                else if(indexPath.row == 2){
                    currentPicker = kTamanoPicker
                }
                    
                else if(indexPath.row == 3){
                    currentPicker = kLineaPicker
                }
                else if(indexPath.row == 4){
                    currentPicker = kCiudadRetiroPicker
                }
                else if(indexPath.row == 6){
                    currentPicker = kCiudadDestinoPicker
                }
                else if(indexPath.row == 7){
                    currentPicker = kPatioDestinoPicker;
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
            return (dataPatiosRetiro?.count)!
        }
        else if(currentPicker == kTipoPicker){
            return (dataTipos?.count)!
        }
        else if(currentPicker == kLineaPicker){
            return (dataLines?.count)!
        }
        else if (currentPicker == kCiudadDestinoPicker || currentPicker == kCiudadRetiroPicker){
            return (dataCiudades?.count)!
        }
        else if(currentPicker == kPatioDestinoPicker){
            return (dataPatiosDestino?.count)!
        }
            
        else
        {
            return (dataTamaños?.count)!
        }
        
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentPicker == kPatioPicker){
            let dict = dataPatiosRetiro?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
            
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            return dict.object(forKey: "code") as? String
        }
        else if(currentPicker == kTipoPicker){
            return dataTipos?.object(at: row) as? String
        }
        else if(currentPicker == kTamanoPicker){
            return dataTamaños?.object(at: row) as? String
        }
        else if(currentPicker == kPatioDestinoPicker){
            let dict = dataPatiosDestino?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
            
        }
        else{
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
        }
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(currentPicker == kPatioPicker){
            let dict = dataPatiosRetiro?.object(at: row) as! NSDictionary
            self.patioPicked = (dict.object(forKey: "code") as? String)!
            selectedPatio = row;
            let cell = self.tableView.cellForRow(at: IndexPath(row: 5, section: 0))
            cell?.detailTextLabel?.text = self.patioPicked
            print(self.patioPicked)
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            self.linePicked = (dict.object(forKey: "code") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))
            cell?.detailTextLabel?.text = self.linePicked
            print(self.linePicked)
        }
        else if(currentPicker == kTipoPicker){
            self.tipoPicked = (dataTipos?.object(at: row) as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
            cell?.detailTextLabel?.text = self.tipoPicked
            print(self.tipoPicked)
            
            
        }
        else if(currentPicker == kTamanoPicker){
            self.tamanoPicked = (dataTamaños?.object(at: row) as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))
            cell?.detailTextLabel?.text = self.tamanoPicked
            print(self.tamanoPicked)
        }
        else if(currentPicker == kCiudadRetiroPicker){
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            self.ciudadRetiroPicked = (dict.object(forKey: "name") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 0))
            cell?.detailTextLabel?.text = self.ciudadRetiroPicked
            print(self.ciudadRetiroPicked)
            self.filterDataPatios(codigoCiudad: (dict.object(forKey: "code") as? String)!, picker: currentPicker, updating: true)
            
        }
        else if(currentPicker == kCiudadDestinoPicker){
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            self.ciudadDestinoPicked = (dict.object(forKey: "name") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 6, section: 0))
            cell?.detailTextLabel?.text = self.ciudadDestinoPicked
            print(self.ciudadDestinoPicked)
            self.filterDataPatios(codigoCiudad: (dict.object(forKey: "code") as? String)!, picker: currentPicker, updating: true)
            
        }
        else if(currentPicker == kPatioDestinoPicker){
            let dict = dataPatiosDestino?.object(at: row) as! NSDictionary
            self.patioDestinoPicked = (dict.object(forKey: "code") as? String)!
            selectedPatioDestino = row;
            let cell = self.tableView.cellForRow(at: IndexPath(row: 7, section: 0))
            cell?.detailTextLabel?.text = self.patioDestinoPicked
            print(self.patioDestinoPicked)
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
        
        let tipo = tipoPicked
        
        if(tipo == ""){
            return nil
        }
        else{
            info.setObject(tipo, forKey: "Tipo" as NSCopying)
        }
        
        let ciudad = self.ciudadRetiroPicked
        if(ciudad == ""){
            
            return nil
        }
        else{
            info.setObject(ciudad, forKey: "Ciudad" as NSCopying)
        }
        
        let ciudadDestino = self.ciudadDestinoPicked
        
        if(ciudadDestino == ""){
            return nil
        }
        else {
            info.setObject(ciudadDestino, forKey: "Ciudad Destino" as NSCopying);
        }
        
        let patioDestino = self.patioDestinoPicked
        if(patioDestino == ""){
            return nil
        }
        else{
            info.setObject(patioDestino, forKey: "Patio Destino" as NSCopying);
        }
        let dict = dataPatiosRetiro?.object(at: selectedPatio) as! NSDictionary
        let patioCode = (dict.object(forKey: "code") as? String)!
        info.setObject(patioCode, forKey: "patioCode" as NSCopying);
        
        let dict2 = dataPatiosDestino?.object(at: selectedPatioDestino) as! NSDictionary
        let patioCode2 = (dict2.object(forKey: "code") as? String)!
        info.setObject(patioCode2, forKey: "patioCodeDestino" as NSCopying);
        
        return info
    }

    
    

    
    
    
}
