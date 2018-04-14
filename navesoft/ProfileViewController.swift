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
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Editar Perfil"
        navigationBar.tintColor = BLUE_COLOR
        let rightButton =  UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ProfileViewController.doneClicked))
        navigationItem.rightBarButtonItem = rightButton
        let leftButton =  UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ProfileViewController.cancelPressed(_:)))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = UIColor.whiteColor();
        
        tableView = UITableView(frame: CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64), style:  .Grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.view.addSubview(tableView)
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        natural = true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        if(cell==nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        cell?.accessoryType = .None
        
        let user = Brain.sharedBrain().currentUser
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.NumberPad;
                textField.autocorrectionType = .No
                textField.returnKeyType = .Done;
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
                textField.font = UIFont.systemFontOfSize(14)
                textField.delegate = self
                textField.tag = kTextFieldTag
                textField.text = user?.cedula
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "No. de Cédula:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 1)
            {
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.Default;
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .Words
                textField.returnKeyType = .Next;
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
                textField.delegate = self
                textField.font = UIFont.systemFontOfSize(14)
                textField.tag = kTextFieldTag
                textField.text = user?.nombre
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "Nombre:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 2){
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.NumberPad;
                textField.autocorrectionType = .No
                textField.returnKeyType = .Done;
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
                textField.delegate = self
                textField.text = user?.celular
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                textField.font = UIFont.systemFontOfSize(14)
                
                cell?.textLabel!.text = "Celular:"
                cell?.textLabel?.textColor = BLUE_COLOR
            }
            else if(indexPath.row == 3){
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.Default;
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .AllCharacters
                textField.returnKeyType = .Done;
                textField.font = UIFont.systemFontOfSize(14)
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
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
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.text = user?.tipo
                textField.keyboardType = UIKeyboardType.Default;
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .AllCharacters
                textField.returnKeyType = .Next;
                textField.font = UIFont.systemFontOfSize(14)
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
                textField.delegate = self
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                
                cell?.textLabel!.text = "Tipo:"
                cell?.textLabel?.textColor = BLUE_COLOR
                
            }
            else if(indexPath.row == 1){
                let textField = UITextField(frame: CGRectMake(140, 7.5, 185, 30))
                textField.adjustsFontSizeToFitWidth = true
                textField.textColor = UIColor.blackColor()
                textField.placeholder = "";
                textField.keyboardType = UIKeyboardType.Default;
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .AllCharacters
                textField.returnKeyType = .Next;
                textField.backgroundColor = UIColor.whiteColor()
                textField.textAlignment = .Left
                textField.font = UIFont.systemFontOfSize(14)
                textField.delegate = self
                textField.tag = kTextFieldTag
                cell?.contentView.addSubview(textField)
                cell?.selectionStyle = UITableViewCellSelectionStyle.Gray
                //cell?.userInteractionEnabled = false
                textField.text = user?.empresa
                cell?.textLabel!.text = "Empresa:"
                cell?.textLabel?.textColor = UIColor.lightGrayColor()
                
                
            }
        }
        else{
            cell?.textLabel?.text = "Cerrar Sesión"
            cell?.textLabel?.textColor = BLUE_COLOR
            cell?.textLabel?.font = UIFont.boldSystemFontOfSize(15.0)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 0){
            
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
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
                    self.presentViewController(SearchViewController(), animated: true, completion: nil)
                }
            }
        }
        else{
            self.presentingViewController?.dismissViewControllerAnimated(false, completion: {
                Brain.sharedBrain().currentUser = nil
                Brain.sharedBrain().save()
               (UIApplication.sharedApplication().delegate as! AppDelegate).signOut()
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func returnValues(value: String) {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
        let textView:UITextField = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField
        textView.text = value
        
        if(value == "Persona Natural"){
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            natural = true
            cell?.textLabel?.textColor = UIColor.lightGrayColor()
        }
        else{
            cell?.selectionStyle = UITableViewCellSelectionStyle.Gray
            natural = false
            cell?.textLabel!.text = "Empresa:"
            cell?.textLabel?.textColor = BLUE_COLOR
        }
    }
    func cancelPressed(sender:AnyObject){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        let tipoText = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField
        let empresaText = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField
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
                self.presentViewController(SearchViewController(), animated: true, completion: nil)
            }
        }
        
        let numberText = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField
        let cedulaText = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField
        if(numberText == textField||cedulaText == textField){
            let done:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: textField, action: #selector(UIResponder.resignFirstResponder))
            done.tintColor = BLUE_COLOR
            let toolbar:UIToolbar = UIToolbar(frame: CGRectMake(0,0,self.view.bounds.size.width,40))
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setCompanySelected(company:String){
        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text = company
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
        let cedula = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let nombre = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let celular = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let placas = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let type = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text
        let company =  (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))?.viewWithTag(kTextFieldTag) as! UITextField).text
        
        if(cedula == "" || nombre == "" || celular == "" || placas == "" || type == ""){
            let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "Por favor completar todos los campos.", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            return;
        }
        SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
        SwiftSpinner.show("Conectando...")
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/updateDriver")!)
        request.HTTPMethod = "POST"
        var postString = ""
        if(type == "Persona Jurídica"){
            postString = "cedula=\(cedula!)&name=\(nombre!)&phone=\(celular!)&plates=\(placas!)&type=\(type!)&company=\(company!)";
        }
        else{
            postString = "cedula=\(cedula!)&name=\(nombre!)&phone=\(celular!)&plates=\(placas!)&type=\(type!)";
        }
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                
                
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
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
            
                dispatch_async(dispatch_get_main_queue(),{
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                });
                
                
            
        }
        task.resume()
        
        
    }

}
