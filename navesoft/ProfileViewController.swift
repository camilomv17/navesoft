//
//  ProfileViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 4/17/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
class ProfileViewController: UIViewController,UINavigationBarDelegate, UITableViewDataSource,UITextFieldDelegate,UITableViewDelegate,DataPickerDelegate {
    
    var tableView = UITableView()
    let kTextFieldTag = 3
    var natural = true
    
    override func viewDidLoad() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.white
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Editar Perfil"
        navigationBar.tintColor = BLUE_COLOR
        let rightButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfileViewController.doneClicked))
        navigationItem.rightBarButtonItem = rightButton
        let leftButton =  UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ProfileViewController.cancelPressed(_:)))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = UIColor.white;
        
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.size.height-64), style:  .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.view.addSubview(tableView)
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        natural = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        if(cell==nil){
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }
        cell?.accessoryType = .none
        
        let user = Brain.sharedBrain().currentUser
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.numberPad;
                textField.autocorrectionType = .no
                textField.returnKeyType = .done;
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.delegate = self
                textField.tag = kTextFieldTag
                textField.text = user?.cedula
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "No. de Cédula:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 1)
            {
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.default;
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .words
                textField.returnKeyType = .next;
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.delegate = self
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.tag = kTextFieldTag
                textField.text = user?.nombre
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "Nombre:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 2){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.numberPad;
                textField.autocorrectionType = .no
                textField.returnKeyType = .done;
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.delegate = self
                textField.text = user?.celular
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                textField.font = UIFont.systemFont(ofSize: 14)
                
                cell?.textLabel!.text = "Celular:"
                cell?.textLabel?.textColor = BLUE_COLOR
            }
            else if(indexPath.row == 3){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.default;
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .allCharacters
                textField.returnKeyType = .done;
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.delegate = self
                textField.tag = kTextFieldTag
                textField.text = user?.placas
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "Placas:"
                cell?.textLabel?.textColor = BLUE_COLOR
            }
        }
        else if(indexPath.section == 1){
            if(indexPath.row == 0){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.text = user?.tipo
                textField.keyboardType = UIKeyboardType.default;
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .allCharacters
                textField.returnKeyType = .next;
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.delegate = self
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "Tipo:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 1){
                let textField = UITextField(frame: CGRect(x: 140, y: 7.5, width: 185, height: 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.black
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.default;
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .allCharacters
                textField.returnKeyType = .next;
                textField.backgroundColor = UIColor.white
                textField.textAlignment = .left
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.delegate = self
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                cell?.selectionStyle = UITableViewCellSelectionStyle.gray
                //cell?.userInteractionEnabled = false
                textField.text = user?.empresa
                cell?.textLabel!.text = "Empresa:"
                cell?.textLabel?.textColor = UIColor.lightGray
                
                
            }
        }
        else{
            cell?.textLabel?.text = "Cerrar Sesión"
            cell?.textLabel?.textColor = BLUE_COLOR
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section  == 0){
            return "Información Personal"
        }
        else if(section == 1){
            return "Información Laboral"
        }
        else{
            return "";
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 0){
            
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.viewWithTag(kTextFieldTag)?.becomeFirstResponder()
        }
        else if(indexPath.section == 1){
            if(indexPath.row == 0){
                self.view.endEditing(true)
                let t = DataPickerView(frame: self.view.bounds, data: NSArray(array: ["Persona Natural","Persona Jurídica"]), title: "Tipo de Persona")
                t.delegate = self
                t.appear()
            }
            else if(indexPath.row == 1){
                if(!natural){
                    self.view.endEditing(true)
                    self.present(SearchViewController(), animated: true, completion: nil)
                }
            }
        }
        else{
            self.presentingViewController?.dismiss(animated: false, completion: {
                Brain.sharedBrain().currentUser = nil
                Brain.sharedBrain().save()
               (UIApplication.shared.delegate as! AppDelegate).signOut()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 4
        }
        else if(section == 1) {
            return 2
        }
        else{
            return 1
        }
    }
    
    func returnValues(_ value: String) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
        let textView:UITextField = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField
        textView.text = value
        
        if(value == "Persona Natural"){
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            natural = true
            cell?.textLabel?.textColor = UIColor.lightGray
        }
        else{
            cell?.selectionStyle = UITableViewCellSelectionStyle.gray
            natural = false
            cell?.textLabel!.text = "Empresa:"
            cell?.textLabel?.textColor = BLUE_COLOR
        }
    }
    func cancelPressed(_ sender:AnyObject){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let tipoText = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField
        let empresaText = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField
        if(textField == tipoText){
            textField.resignFirstResponder()
            let t = DataPickerView(frame: self.view.bounds, data: NSArray(array: ["Persona Natural","Persona Jurídica"]), title: "Tipo de Persona")
            t.delegate = self
            t.appear()
        }
        else if(textField == empresaText){
            
            textField.resignFirstResponder()
            if(!natural){
                self.view.endEditing(true)
                self.present(SearchViewController(), animated: true, completion: nil)
            }
        }
        
        let numberText = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField
        let cedulaText = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField
        if(numberText == textField||cedulaText == textField){
            let done:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: textField, action: #selector(UIResponder.resignFirstResponder))
            done.tintColor = BLUE_COLOR
            let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.bounds.size.width,height: 40))
            toolbar.items = [done]
            textField.inputAccessoryView = toolbar
        }
        /*  if(textField == tipoText){
         textField.resignFirstResponder()
         let t = DataPickerView(frame: self.view.bounds, data: NSArray(array: ["Persona Natural","Persona Jurídica"]), title: "Tipo de Persona")
         t.delegate = self
         t.appear()
         }
         else if(textField == empresaText){
         textField.resignFirstResponder()
         self.presentViewController(SearchViewController(), animated: true, completion: nil)
         }
         }
         func textFieldShouldReturn(textField: UITextField) -> Bool {
         if(textField == cedulaText){
         nombreText?.becomeFirstResponder()
         }
         else if(textField == nombreText){
         celularText?.becomeFirstResponder()
         }
         else{
         textField.resignFirstResponder()
         }
         return true
         */
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setCompanySelected(_ company:String){
        (self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text = company
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section != 2){
        if(Brain.isIphone4()){
            return 25
        }
        else{
            return 40;
        }
        }
        else{
            return 10;
        }
    }
    
    func doneClicked(){
        let cedula = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let nombre = (self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let celular = (self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let placas = (self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let type = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let company =  (self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text
        
        if(cedula == "" || nombre == "" || celular == "" || placas == "" || type == ""){
            let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "Por favor completar todos los campos.", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
            return;
        }
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
        SwiftSpinner.show("Conectando...")
        
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/updateDriver")!)
        request.httpMethod = "POST"
        var postString = ""
        if(type == "Persona Jurídica"){
            postString = "cedula=\(cedula!)&name=\(nombre!)&phone=\(celular!)&plates=\(placas!)&type=\(type!)&company=\(company!)";
        }
        else{
            postString = "cedula=\(cedula!)&name=\(nombre!)&phone=\(celular!)&plates=\(placas!)&type=\(type!)";
        }
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                
                
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            
            let user = Brain.sharedBrain().currentUser
            user?.nombre = nombre
            user?.cedula = cedula
            user?.celular = celular
            user?.placas = placas
            user?.tipo = type
            if(company != ""){
                user?.empresa = company
            }
            SwiftSpinner.hide()
            Brain.sharedBrain().save();
            
                DispatchQueue.main.async(execute: {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                });
                
                
            
        }) 
        task.resume()
        
        
    }

}
