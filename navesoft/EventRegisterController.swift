//
//  EventRegisterController.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import AEXML

class EventRegisterController:UIViewController,UINavigationBarDelegate {
    
    var pickUpView = UIView()
    var deliverRegisterView = UIView()
    var currentSelectedSegment = 0
    var patios:NSArray?
    var lineas:NSArray?
    override func viewDidLoad() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 84)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.white
        navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Registro"
        navigationBar.tintColor = BLUE_COLOR
        // Create left and right button for navigation item
        let rightButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EventRegisterController.doneClicked(_:)))
        // Create two buttons for the navigation item
        navigationItem.rightBarButtonItem = rightButton
        
        let leftButton =  UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EventRegisterController.cancelPressed(_:)))
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)

        
        self.view.backgroundColor = UIColor.white
        
         let segmentedControl = UISegmentedControl (items: ["Retiro","Devolución"])
        segmentedControl.frame = CGRect(x: 20, y: 74,width: self.view.bounds.size.width-40, height: 35)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(EventRegisterController.segmentedControlAction(_:)), for: .valueChanged)
        segmentedControl.tintColor = BLUE_COLOR
        self.view.addSubview(segmentedControl)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
        SwiftSpinner.show("Conectando...")
        
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getPatiosAndLines")!)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            
          
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let patios = json.object(forKey: "patios") as! NSArray
                
                let lines = json.object(forKey: "lines") as! NSArray
                
                let ciudades = json.object(forKey: "ciudades") as! NSArray
                
                self.pickUpView = PickUpRegisterView(frame: CGRect(x: 0,y: 110,width: self.view.bounds.size.width,height: self.view.bounds.size.height - 110),lines: lines,patios: patios, ciudades: ciudades)
                self.deliverRegisterView = DeliverRegisterView(frame: CGRect(x: 0,y: 110,width: self.view.bounds.size.width,height: self.view.bounds.size.height - 110),lines: lines,patios: patios,ciudades: ciudades)
                
                DispatchQueue.main.async(execute: ({
                    self.view.addSubview(self.pickUpView)
                }));
                
               
                
                
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        }) 
        task.resume()
        
    }
    
    func doneClicked(_ sender:AnyObject){
        self.view.endEditing(true);
        if(currentSelectedSegment == 0){
           let dict = (self.pickUpView as! PickUpRegisterView).fetchInfo()
            if(dict == nil){
                let alertController = UIAlertController(title: "Error", message: "Por favor complete todos los campos", preferredStyle: .alert)
                
                // Initialize Actions
                let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    
                }
                
                alertController.addAction(yesAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                
                let booking = dict?.object(forKey: "Booking") as? String
                let tamano = dict?.object(forKey: "Tamano") as? String
                let linea = dict?.object(forKey: "Linea") as? String
                let patio = dict?.object(forKey: "Patio") as? String
                let tipo = dict?.object(forKey: "Tipo") as? String
                let ciudad = dict?.object(forKey: "Ciudad") as? String
                let ciudadDestino = dict?.object(forKey: "Ciudad Destino") as? String
                let patioDestino = dict?.object(forKey: "Patio Destino") as? String
                SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
                SwiftSpinner.show("Conectando...")
                
              
                
                let lastLocation:CLLocation = Brain.sharedBrain().lastLocation!
                
                let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&booking=\(booking!)&tamano=\(tamano!)&line=\(linea!)&patio=\(patio!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)&ciudad=\(ciudad!)&ciudaddes=\(ciudadDestino!)&patiodes=\(patioDestino)&tretiro=\(tipo)";
                 self.checkValid(booking!, postString: postString, type: "E", params: dict)
                
            }
        }
        else{
            let dict = (self.deliverRegisterView as! DeliverRegisterView).fetchInfo()
            if(dict == nil){
                let alertController = UIAlertController(title: "Error", message: "Por favor complete todos los campos", preferredStyle: .alert)
                
                // Initialize Actions
                let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    print("The user is okay.")
                }
                
                alertController.addAction(yesAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let container = dict?.object(forKey: "Contenedor") as? String
                let tamano = dict?.object(forKey: "Tamano") as? String
                let linea = dict?.object(forKey: "Linea") as? String
                let patio = dict?.object(forKey: "Patio") as? String
                let ciudad = dict?.object(forKey: "Ciudad") as? String
                
                if(Brain.isValidContainer(container!) == false){
                    let alertController = UIAlertController(title: "Error", message: "El número del contenedor no es válido", preferredStyle: .alert)
                    
                    // Initialize Actions
                    let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    }
                    
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true, completion: nil)
                    return;
                }
                
                let segundo = dict?.object(forKey: "Contenedor2") as? String
                
                if(segundo != nil){
                    if(Brain.isValidContainer(segundo!)==false){
                        let alertController = UIAlertController(title: "Error", message: "El número del contenedor 2 no es válido", preferredStyle: .alert)
                        
                        // Initialize Actions
                        let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                        }
                        
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true, completion: nil)
                        return;
                    }
                }
                SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
                SwiftSpinner.show("Conectando...")
                
                
                let lastLocation:CLLocation = Brain.sharedBrain().lastLocation!

                
                var postString = ""
                if(segundo != nil){
                     postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&container=\(container!)&line=\(linea!)&patio=\(patio!)&tamano=\(tamano!)&segundo=\(segundo!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)&ciudad=\(ciudad!)";
                }
                else{
                     postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&container=\(container!)&line=\(linea!)&patio=\(patio!)&tamano=\(tamano!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)&ciudad=\(ciudad!)";

                }
                self.checkValid(container!, postString: postString, type: "I", params: dict)
                 //self.postDeliverEvent(postString, booking: container!, params: dict)
                
                

            }

        }
    }
    
    func postPickUpEvent(_ postString:String,params:NSDictionary?){
        SwiftSpinner.show("Conectando...")
        let booking = params?.object(forKey: "Booking") as? String
        let linea = params?.object(forKey: "Linea") as? String
        let patio = params?.object(forKey: "Patio") as? String
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/createPickUpEvent")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 25;
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError();
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()
                self.showNetError()

                
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let patioInfo = json.object(forKey: "patio") as! NSDictionary
                
                let eventId = json.object(forKey: "eventId") as! String
                
                let event = Event()
                event._id = eventId
                
                event.type = "pick"
                event.trailer = booking
                event.linea = linea
                event.patio = patio
                event.destino = patioInfo.object(forKey: "position") as? String
                Brain.sharedBrain().currentEvent = event
                Brain.sharedBrain().save()
                
                SwiftSpinner.hide()
                DispatchQueue.main.async(execute: {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                });
                
                
            }
            catch{
                print("FFUUUUUU")
                SwiftSpinner.hide()
                self.showNetError()

            }
        }) 
        task.resume()
    }
    
    func postDeliverEvent(_ postString:String,params:NSDictionary?){
        let container = params?.object(forKey: "Contenedor") as? String
        let linea = params?.object(forKey: "Linea") as? String
        let patio = params?.object(forKey: "Patio") as? String
        let segundo = params?.object(forKey: "Contenedor2") as? String

        SwiftSpinner.show("Conectando...")
        
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/createDeliverEvent")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 25;

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()
                self.showNetError()
                return;
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let patioInfo = json.object(forKey: "patio") as! NSDictionary
                
                let eventId = json.object(forKey: "eventId") as! String
                
                let event = Event()
                event._id = eventId
                
                event.type = "deliver"
                event.trailer = container
                event.linea = linea
                event.patio = patio
                event.segundo = segundo
                event.destino = patioInfo.object(forKey: "position") as? String
                Brain.sharedBrain().currentEvent = event
                Brain.sharedBrain().save()
                
                SwiftSpinner.hide()
                DispatchQueue.main.async(execute: {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                });
                
                
            }
            catch{
                print("FFUUUUUU")
                SwiftSpinner.hide()

                self.showNetError()
            }
        }) 
        task.resume()
    }
    
    
    func segmentedControlAction(_ sender:UISegmentedControl){
        if(currentSelectedSegment == sender.selectedSegmentIndex){
            return
        }
        currentSelectedSegment = sender.selectedSegmentIndex
        if(currentSelectedSegment == 0){
            self.pickUpView.alpha = 0.0
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.deliverRegisterView.alpha = 0.0
                    
                    self.view.addSubview(self.pickUpView);
                    self.pickUpView.alpha = 1
                    }, completion: {(result:Bool) in self.deliverRegisterView.removeFromSuperview();})
        }
        else{
            self.deliverRegisterView.alpha = 0.0
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.pickUpView.alpha = 0.0
                self.view.addSubview(self.deliverRegisterView);
                self.deliverRegisterView.alpha = 1
                }, completion: { (result:Bool) in self.pickUpView.removeFromSuperview(); })
        }
        
        
    }
    
    func cancelPressed(_ sender:AnyObject){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func checkValid(_ booking:String,postString:String,type:String,params:NSDictionary?){
        
        var empresa:String?;
        var linea:String?;
        var patio:String?;
        var container:String?;
        
        if(type == "E"){
            empresa = Brain.sharedBrain().serverCode;
            linea = params?.object(forKey: "Linea") as? String;
            patio = params?.object(forKey: "patioCode") as? String;
            container = booking;
            
        }
        else{
            empresa = Brain.sharedBrain().serverCode;
            linea = params?.object(forKey: "Linea") as? String;
            patio = params?.object(forKey: "patioCode") as? String;
            
            if(params?.object(forKey: "Contenedor2") != nil){
                container = "\((params?.object(forKey: "Contenedor") as? String)!)_\((params?.object(forKey: "Contenedor"))!)";
            }
            else{
                container = booking;
            }
        }
        
        var parameters:String = "http://190.242.124.185:7778/pls/csavchile/RES_API.get_res?parametro1=\(container!)&parametro2=\(empresa!)&parametro3=\(linea!)&parametro4=\(patio!)"
        parameters = parameters.addingPercentEscapes(using: String.Encoding.utf8)!
        
        let url = URL(string: parameters);
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type");
        request.timeoutInterval = 25;

       // let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
       // let length = CUnsignedLong((data?.length)!)
       // request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
       // request.HTTPBody = data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()

                self.showNetError()
                return;
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do{
                SwiftSpinner.hide();
                let xmlDoc = try AEXMLDocument(xml: data!);
              
                
                let mensaje:String =  xmlDoc.root["mensaje"].value!;
                let flag:String = xmlDoc.root["flag"].value!;
                
                if(flag == "1"){
                    let alertController = UIAlertController(title: "Avizat", message: mensaje, preferredStyle: .alert)
                    
                    // Initialize Actions
                        let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                            if(type=="I"){
                                self.postDeliverEvent(postString, params: params);
                            }
                            else if(type == "E"){
                                self.postPickUpEvent(postString, params: params);
                            }
                        
                    }
                        
                    
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                }
                
                else{
                    let alertController = UIAlertController(title: "Avizat", message: mensaje, preferredStyle: .alert)
                    
                    // Initialize Actions
                    let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                        
                    }
                    
                    
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
                
            }
            catch{
                SwiftSpinner.hide()
                self.showNetError()
                print("FFUUUUUU")
            }
        }) 
        task.resume()

    }
    fileprivate func showNetError(){
        let alertController = UIAlertController(title: "Error", message: "No ha sido posible contactar al servidor", preferredStyle: .alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
        }
        
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
        return;

    }
}
