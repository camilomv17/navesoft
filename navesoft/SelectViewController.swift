//
//  SelectViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 10/9/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

class SelectViewController: UIViewController, UITextFieldDelegate {
    
    var textField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "AviZaT"
        
        self.view.backgroundColor = UIColor.white;
        self.navigationController?.navigationBar.barTintColor = UIColor.white;
        self.navigationController?.navigationBar.tintColor = BLUE_COLOR;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SelectViewController.buttonPressed ))
        
        
        let label = UILabel(frame: CGRect(x: 10,y: self.view.bounds.size.height/2 - 50,width: self.view.bounds.size.width - 20 , height: 50));
        label.text = "Código de empresa";
        label.textColor = UIColor.black;
        label.textAlignment = .center;
        self.view.addSubview(label);
        
        textField = UITextField(frame: CGRect(x: 45,y: self.view.bounds.size.height/2,width: self.view.bounds.size.width - 90, height: 40))
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        
        textField.placeholder = "Código"
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.returnKeyType = .done;
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 14)
        
        self.view.addSubview(textField)
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buttonPressed()
        return true;
    }
    
    
    
    
    func buttonPressed(){
        if(textField.text == ""){
            let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "Por favor completar el campo requerido.", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
            return;

        }
        else{
            self.view.endEditing(true);
            SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
            SwiftSpinner.show("Conectando...")
            let request = NSMutableURLRequest(url: URL(string: "\(SERVER_IP)/api/call/askForHost")!)
            request.httpMethod = "POST"
            let postString = "host=\(textField.text!)"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
            let data = postString.data(using: String.Encoding.utf8)
            let length = CUnsignedLong((data?.count)!)
            request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {                                                          // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                    
                    
                }
                
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(responseString)")
                
                do{
                    SwiftSpinner.hide()
                    let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let status = json.object(forKey: "status") as? String
                    
                    if(status == "OK"){
                        let url = json.object(forKey: "url") as? String
                        Brain.sharedBrain().serverIp = url
                        Brain.sharedBrain().serverCode = self.textField.text!
                        Brain.sharedBrain().save()
                        
                        DispatchQueue.main.async(execute: {
                            self.navigationController?.pushViewController(RegisterViewController(), animated: true);
                        });
                    }
                    else{
                        DispatchQueue.main.async(execute: {

                        let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "El código no es válido.", preferredStyle: .alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
                            //Just dismiss the action sheet
                        }
                        actionSheetController.addAction(cancelAction)
                        self.present(actionSheetController, animated: true, completion: nil)
                        return;
                        });
                    }
                    
                    //Brain.sharedBrain().save();
                    //dispatch_async(dispatch_get_main_queue(),{
                     //   (UIApplication.sharedApplication().delegate as! AppDelegate).finishLogin()
                    //});
                    
                    
                }
                catch{
                    print("FFUUUUUU")
                }
            }) 
            task.resume()
        }
    }
}
