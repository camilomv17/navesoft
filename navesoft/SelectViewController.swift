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
        
        self.view.backgroundColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.tintColor = BLUE_COLOR;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SelectViewController.buttonPressed ))
        
        
        let label = UILabel(frame: CGRectMake(10,self.view.bounds.size.height/2 - 50,self.view.bounds.size.width - 20 , 50));
        label.text = "Código de empresa";
        label.textColor = UIColor.blackColor();
        label.textAlignment = .Center;
        self.view.addSubview(label);
        
        textField = UITextField(frame: CGRectMake(45,self.view.bounds.size.height/2,self.view.bounds.size.width - 90, 40))
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.blackColor().CGColor
        textField.layer.borderWidth = 1
        
        textField.placeholder = "Código"
        textField.autocorrectionType = .No
        textField.textAlignment = .Center
        textField.autocapitalizationType = .AllCharacters
        textField.returnKeyType = .Done;
        textField.delegate = self
        textField.font = UIFont.systemFontOfSize(14)
        
        self.view.addSubview(textField)
        
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        buttonPressed()
        return true;
    }
    
    
    
    
    func buttonPressed(){
        if(textField.text == ""){
            let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "Por favor completar el campo requerido.", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            return;

        }
        else{
            self.view.endEditing(true);
            SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
            SwiftSpinner.show("Conectando...")
            let request = NSMutableURLRequest(URL: NSURL(string: "\(SERVER_IP)/api/call/askForHost")!)
            request.HTTPMethod = "POST"
            let postString = "host=\(textField.text!)"
            
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
                
                do{
                    SwiftSpinner.hide()
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let status = json.objectForKey("status") as? String
                    
                    if(status == "OK"){
                        let url = json.objectForKey("url") as? String
                        Brain.sharedBrain().serverIp = url
                        Brain.sharedBrain().serverCode = self.textField.text!
                        Brain.sharedBrain().save()
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            self.navigationController?.pushViewController(RegisterViewController(), animated: true);
                        });
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(),{

                        let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "El código no es válido.", preferredStyle: .Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
                            //Just dismiss the action sheet
                        }
                        actionSheetController.addAction(cancelAction)
                        self.presentViewController(actionSheetController, animated: true, completion: nil)
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
            }
            task.resume()
        }
    }
}
