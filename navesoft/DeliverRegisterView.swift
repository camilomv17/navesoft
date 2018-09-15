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
    let kCiudadPicker = 3
    
    
    let kPatioDestinoPicker = 4;
    let kCiudadDestinoPicker = 5;
    let kLineaDestinoPicker = 6;
    let kTipoDestinoPicker = 7;
    let kTamanoDestinoPicker = 8;
    
    
    var tableView = UITableView()
    var pickerCellRowHeight = 162.0
    var datePickerIndexPath:IndexPath?
    var patioPicker:UIPickerView?
    var initialTvHeight = CGFloat(0.0)
    let kPatioPickerTag = 1
    let kTextFieldChildTag = 10
    let kSwitchTag = 11
    
    var dataLines:NSArray?
    var dataPatios:NSArray?
    var currentPicker = 0
    var patioPicked = ""
    var linePicked = ""
    var tamanoPicked = ""
    var ciudadPicked = ""
    var selectedPatio = 0;
    var extraContainer = false
    var dobleEvento = false
    
    //Evento de regreso
     var tipoPicked = "";
    var ciudadDestinoPicked = "";
    var patioDestinoPicked = "";
    var tamanoDestinoPicked = "";
    var lineaDestinoPicked = "";
    var selectedPatioDestino = 0;
    var dataTipos:NSArray?
    
    var currentSectionShowingPicker = 0;
    var retiroSwitchIsOn = false;
    
    var dataTamaños:NSArray?
    var dataCiudades:NSArray?
    var dataPatiosDevolucion:NSMutableArray?
    var dataPatiosDestino:NSMutableArray?
    init(frame: CGRect,lines:NSArray,patios:NSArray,ciudades:NSArray) {
        super.init(frame: frame)
        currentPicker = 0;
        retiroSwitchIsOn = false;
        dobleEvento = false
        selectedPatio = 0;
        currentSectionShowingPicker = 0;
        self.dataLines = lines;
        self.dataPatios = patios;
        self.dataCiudades = ciudades
        tableView = UITableView(frame: self.bounds, style: .grouped)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = UIColor.white
        self.addSubview(tableView)
        initialTvHeight = tableView.frame.size.height
        dataTamaños = ["20 (un contenedor)","20 (dos contenedores)","40"]
        dataTipos = ["EXPO","REPO"];
        
        let firstCity = (dataCiudades?.object(at: 0) as! NSDictionary).value(forKey: "code") as! String;
        filterDataPatios(codigoCiudad: firstCity, picker: kCiudadPicker, updating: false)
        filterDataPatios(codigoCiudad: firstCity, picker: kCiudadDestinoPicker, updating: false)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func filterDataPatios(codigoCiudad:String, picker: Int , updating: Bool){
        if(picker == kCiudadPicker){
            dataPatiosDevolucion = NSMutableArray();
        
        
        
            for patio in dataPatios! {
                let temp = patio as! NSDictionary
                if (temp.object(forKey: "city") as! String == codigoCiudad ){
                    dataPatiosDevolucion?.add(temp);
                }
            }
            if(updating){
                var extraRow = 0;
                if(extraContainer){
                    extraRow = 1;
                }
                let index = IndexPath(item: 5+extraRow, section: 0)
                let cell = self.tableView.cellForRow(at: index) as! UITableViewCell
                cell.detailTextLabel?.text = (dataPatiosDevolucion?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String;
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
               
                let index = IndexPath(item: 6, section: 1)
                let cell = self.tableView.cellForRow(at: index) as! UITableViewCell
                cell.detailTextLabel?.text = (dataPatiosDestino?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String;
                selectedPatioDestino = 0
            }
        }
       
        
    }
    
    func datePickerIsShown() ->Bool{
        return self.datePickerIndexPath != nil
    }
    
    func hideExistingPicker(){
        self.tableView.deleteRows(at: [self.datePickerIndexPath!], with: .fade)
        self.datePickerIndexPath = nil
    }
    
    func calculateInexPathForNewPicker(_ selectedIndexPath:IndexPath) ->IndexPath
    {
        let newIndexPath:IndexPath
        
        if(self.datePickerIsShown() && self.datePickerIndexPath?.row < selectedIndexPath.row && selectedIndexPath.section == self.datePickerIndexPath?.section){
            newIndexPath = IndexPath(row: selectedIndexPath.row-1, section: selectedIndexPath.section)
        }
        else{
            newIndexPath = IndexPath(row: selectedIndexPath.row, section: selectedIndexPath.section)
        }
        
        return newIndexPath
    }
    
    func showNewPickerAtIndex(_ indexPath:IndexPath){
        let  indexPaths = [IndexPath(row: indexPath.row + 1, section: indexPath.section)]
        
        self.tableView.insertRows(at: indexPaths, with: .fade)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row && indexPath.section == self.datePickerIndexPath?.section)){
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
                
                cell?.textLabel!.text = "N. Contenedor  "
                
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
                    
                    cell?.textLabel!.text = "N. Contenedor 2  "
                    
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
                
                cell?.textLabel?.text = "Ciudad"
                cell?.detailTextLabel?.text = (dataCiudades?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                self.ciudadPicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 4+extraCell){
                
                cell?.textLabel?.text = "Patio"
                cell?.detailTextLabel?.text = (dataPatiosDevolucion?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                self.patioPicked = (cell?.detailTextLabel?.text)!
                
            }
            else if(indexPath.row == 5+extraCell){
                cell?.textLabel?.text = "Retiro"
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(false, animated: true)
                switchView.tag = kSwitchTag
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell?.accessoryView = switchView
            }
            return cell!
        }
        
        
        
        }
        else{
            if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row && indexPath.section == self.datePickerIndexPath?.section)){
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
                var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell2")
                if(cell==nil){
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell2")
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
                    
                    cell?.textLabel!.text = "Booking/Reserva  "
                    
                }

                if(indexPath.row == 1){
                    cell?.textLabel?.text = "Tipo"
                    cell?.detailTextLabel?.text = dataTipos![0] as? String
                    self.tipoPicked = (cell?.detailTextLabel?.text)!
                }
                else if(indexPath.row == 2){
                    cell?.textLabel?.text = "Tamaño"
                    cell?.detailTextLabel?.text = dataTamaños![0] as? String
                    self.tamanoDestinoPicked = (cell?.detailTextLabel?.text)!
                    
                }
                    
                else if(indexPath.row == 3){
                    cell?.textLabel?.text = "Linea Destino"
                    cell?.detailTextLabel?.text = (dataLines?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                    self.lineaDestinoPicked = (cell?.detailTextLabel?.text)!
                    
                }
                    
                else if(indexPath.row == 4){
                    
                    cell?.textLabel?.text = "Ciudad Destino"
                    cell?.detailTextLabel?.text = (dataCiudades?.object(at: 0) as! NSDictionary).object(forKey: "name") as? String
                    self.ciudadDestinoPicked = (cell?.detailTextLabel?.text)!
                    
                }
                else if(indexPath.row == 5){
                    
                    cell?.textLabel?.text = "Patio Destino"
                    cell?.detailTextLabel?.text = (dataPatiosDestino?.object(at: 0) as! NSDictionary).object(forKey: "code") as? String
                    self.patioDestinoPicked = (cell?.detailTextLabel?.text)!
                    
                }
                
                return cell!
            }
            
        }
        
        
    }
    
    func switchChanged(_ sender : UISwitch!){
        
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        retiroSwitchIsOn = sender.isOn;
        if(sender.isOn){
            dobleEvento = true
            tableView.beginUpdates()
            tableView.insertSections(IndexSet.init(integer: 1), with: .fade)
            tableView.endUpdates()
            
        }
        else{
            dobleEvento = false
            tableView.beginUpdates()
            tableView.deleteSections(IndexSet.init(integer: 1), with: .fade)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
        var numberOfRows = 6
            if(self.datePickerIsShown() && self.datePickerIndexPath?.section == section){
            numberOfRows = numberOfRows+1;
        }
        if(self.extraContainer){
            numberOfRows = numberOfRows+1;
        }
        return numberOfRows;
            
        }
        else {
            var numberOfRows = 6
            if(self.datePickerIsShown() && self.datePickerIndexPath?.section == section){
                numberOfRows = numberOfRows+1;
            }
            return numberOfRows;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.tableView.beginUpdates()
        
        if(self.datePickerIsShown() && self.datePickerIndexPath!.row - 1 == indexPath.row && self.datePickerIndexPath?.section == indexPath.section ){
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
            if(indexPath.section == 0){

            if(indexPath.row == 1+extraCell || indexPath.row == 2+extraCell || indexPath.row == 3+extraCell || indexPath.row == 4+extraCell){
                self.endEditing(true)
                let newPickerIndexPath = self.calculateInexPathForNewPicker(indexPath)
                self.showNewPickerAtIndex(newPickerIndexPath)
                
                if(indexPath.row == 2+extraCell){
                    currentPicker = kLineaPicker
                }
                else if(indexPath.row == 3+extraCell){
                    currentPicker = kCiudadPicker
                }
                else if(indexPath.row == 4 + extraCell){
                    currentPicker = kPatioPicker
                }
                else{
                    currentPicker = kTamanoPicker
                }
                self.patioPicker?.reloadAllComponents()
                
                self.datePickerIndexPath = IndexPath(row: newPickerIndexPath.row + 1, section: indexPath.section)
            }
            else if(indexPath.row == 5+extraCell){
                let cell = self.tableView.cellForRow(at: indexPath)
                let sender = (cell?.viewWithTag(kSwitchTag) as? UISwitch)
                sender?.setOn(((sender?.isOn)! ? false : true), animated: true)
                self.switchChanged(sender)
            }
            else{
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.viewWithTag(kTextFieldChildTag)?.becomeFirstResponder()
            }
            }
            else{
                if(indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5){
                    self.endEditing(true)
                    let newPickerIndexPath = self.calculateInexPathForNewPicker(indexPath)
                    self.showNewPickerAtIndex(newPickerIndexPath)
                    
                    if(indexPath.row == 1){
                        currentPicker = kTipoDestinoPicker
                    }
                    else if(indexPath.row == 2){
                        currentPicker = kTamanoDestinoPicker
                    }
                    else if(indexPath.row == 3 ){
                        currentPicker = kLineaDestinoPicker
                    }
                    else if(indexPath.row == 4){
                        currentPicker = kCiudadDestinoPicker
                    }
                    else {
                        currentPicker = kPatioDestinoPicker
                    }
                    self.patioPicker?.reloadAllComponents()
                    
                    self.datePickerIndexPath = IndexPath(row: newPickerIndexPath.row + 1, section: indexPath.section)
                }
                else{
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.viewWithTag(kTextFieldChildTag)?.becomeFirstResponder()
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.endUpdates()
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(dobleEvento){
            return 2
        }
        else{
            return 1;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = 45.0
        
        if(self.datePickerIsShown() && (self.datePickerIndexPath?.row == indexPath.row) && self.datePickerIndexPath?.section == indexPath.section){
            rowHeight = self.pickerCellRowHeight
        }
        
        return CGFloat(rowHeight);
        
        
        
    }
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
                return "Datos para devolución de contenedor"
        }
        else{
            return "Datos para Retiro de contenedor"
        }
        
    }
    
    
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentPicker == kPatioPicker){
            return (dataPatiosDevolucion?.count)!
        }
        else if(currentPicker == kPatioDestinoPicker){
            return (dataPatiosDestino?.count)!
        }
        else if(currentPicker == kLineaPicker || currentPicker == kLineaDestinoPicker){
            return (dataLines?.count)!
        }
        else if(currentPicker == kCiudadPicker || currentPicker == kCiudadDestinoPicker ){
            return (dataCiudades?.count)!
        }
        else if(currentPicker == kTipoDestinoPicker){
            return (dataTipos?.count)!
        }
        else {
            return (dataTamaños?.count)!
        }
        
    }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentPicker == kPatioPicker){
            let dict = dataPatiosDevolucion?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
            
        }
        else if(currentPicker == kPatioDestinoPicker){
            let dict = dataPatiosDestino?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
            
        }
        else if(currentPicker == kLineaPicker || currentPicker == kLineaDestinoPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            return dict.object(forKey: "code") as? String
        }
        else if(currentPicker == kCiudadPicker || currentPicker == kCiudadDestinoPicker){
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            return dict.object(forKey: "name") as? String
        }
        else if(currentPicker == kTipoDestinoPicker){
            return dataTipos?.object(at: row) as? String
        }
        else{
            return dataTamaños?.object(at: row) as? String
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var extraRow = 0;
        if(extraContainer){
            extraRow = 1;
        }
        if(currentPicker == kPatioPicker){
            let dict = dataPatiosDevolucion?.object(at: row) as! NSDictionary
            self.patioPicked = (dict.object(forKey: "name") as? String)!
            selectedPatio = row;
            let cell = self.tableView.cellForRow(at: IndexPath(row: 4+extraRow, section: 0))
            cell?.detailTextLabel?.text = self.patioPicked
            print(self.patioPicked)
        }
            
       else if(currentPicker == kPatioDestinoPicker){
            let dict = dataPatiosDestino?.object(at: row) as! NSDictionary
            self.patioDestinoPicked = (dict.object(forKey: "name") as? String)!
            selectedPatioDestino = row;
            let cell = self.tableView.cellForRow(at: IndexPath(row: 5, section: 1))
            cell?.detailTextLabel?.text = self.patioDestinoPicked
            print(self.patioDestinoPicked)
        }
        else if(currentPicker == kLineaPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            self.linePicked = (dict.object(forKey: "code") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 2+extraRow, section: 0))
            cell?.detailTextLabel?.text = self.linePicked
            print(self.linePicked)
        }
        else if(currentPicker == kLineaDestinoPicker){
            let dict = dataLines?.object(at: row) as! NSDictionary
            self.lineaDestinoPicked = (dict.object(forKey: "code") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 1))
            cell?.detailTextLabel?.text = self.lineaDestinoPicked
            print(self.lineaDestinoPicked)
        }
        else if(currentPicker == kCiudadPicker){
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            self.ciudadPicked = (dict.object(forKey: "name") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 3+extraRow, section: 0))
            cell?.detailTextLabel?.text = self.ciudadPicked
            print(self.ciudadPicked)
            self.filterDataPatios(codigoCiudad: (dict.object(forKey: "code") as? String)!,picker: kCiudadPicker, updating: true)
        }
        else if(currentPicker == kCiudadDestinoPicker){
            let dict = dataCiudades?.object(at: row) as! NSDictionary
            self.ciudadDestinoPicked = (dict.object(forKey: "name") as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 1))
            cell?.detailTextLabel?.text = self.ciudadDestinoPicked
            print(self.ciudadDestinoPicked)
            self.filterDataPatios(codigoCiudad: (dict.object(forKey: "code") as? String)!,picker: kCiudadDestinoPicker, updating: true)
        }
        else if(currentPicker == kTamanoPicker){
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
        else if(currentPicker == kTamanoDestinoPicker){
            self.tamanoDestinoPicked = (dataTamaños?.object(at: row) as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
            cell?.detailTextLabel?.text = self.tamanoDestinoPicked
            print(self.tamanoDestinoPicked)
        }
        else if(currentPicker == kTipoDestinoPicker){
            self.tipoPicked = (dataTipos?.object(at: row) as? String)!
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
            cell?.detailTextLabel?.text = self.tipoPicked
            print(self.tipoPicked)

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
        
        let ciudad = self.ciudadPicked
        
        if(ciudad == ""){
            return nil
        }
        else{
            info.setObject(ciudad, forKey: "Ciudad" as NSCopying)
        }
        
        if(retiroSwitchIsOn){
            
            info.setObject(retiroSwitchIsOn, forKey: "RetiroSwitch" as NSCopying)
            
           let bookingRetiro = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.viewWithTag(kTextFieldChildTag) as! UITextField).text
            if(bookingRetiro == ""){
                return nil
            }
            else{
                info.setObject(bookingRetiro!, forKey: "BookingRetiro" as NSCopying)
                
            }
            
            let tipoRetiro = self.tipoPicked
            
            if(tipoRetiro == ""){
                return nil
            }
            else{
                info.setObject(tipoRetiro, forKey: "TipoRetiro" as NSCopying)
            }
            
            let tamanoRetiro = self.tamanoDestinoPicked
            if(tamanoRetiro == ""){
                return nil
            }
            else{
                info.setObject(tamanoRetiro, forKey: "TamanoRetiro" as NSCopying)
            }
            
            let lineaDestino = self.lineaDestinoPicked
            if(lineaDestino == ""){
                return nil
            }
            else{
                info.setObject(lineaDestino, forKey: "LineaDestino" as NSCopying)
            }
            
            let ciudadDestino = self.ciudadDestinoPicked
            if(ciudadDestino == ""){
                return nil
            }
            else {
                info.setObject(ciudadDestino, forKey: "CiudadDestino" as NSCopying)
            }
            
            let patioDestino = self.patioDestinoPicked
            
            if(patioDestino == ""){
                return nil
            }
            else{
                info.setObject(patioDestino, forKey: "PatioDestino" as NSCopying)
            }
            
        }
        
        
        let dict = dataPatiosDevolucion?.object(at: selectedPatio) as! NSDictionary
        let patioCode = (dict.object(forKey: "code") as? String)!
        info.setObject(patioCode, forKey: "patioCode" as NSCopying);
        
        let dict2 = dataPatiosDestino?.object(at: selectedPatioDestino) as! NSDictionary
        let patioDestinoCode = (dict.object(forKey: "code") as? String)!
        info.setObject(patioDestinoCode, forKey: "patioDestinoCode" as NSCopying)
        return info
    }
    

  



    
}
