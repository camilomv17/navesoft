//
//  MainViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MainViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate{
    
    let kNavigationViewTag = 15
    let kConfirmButton = 16
    let kMessageButtonTag = 17
    
    var googleMap:GMSMapView?
    var locationManager:CLLocationManager?
    var driverMarker:GMSMarker?
    
    var lastHeading = 0.0
    var lastLocation:CLLocation?
    
    
    var polylineLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "AviZaT"
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = BLUE_COLOR
        
        
        
        polylineLoaded = false
        
         let plus =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.servicePressed(_:)))
        self.navigationItem.rightBarButtonItem = plus
        let profile = UIBarButtonItem(image: UIImage(named: "profile-icon.png"), style: .plain, target: self, action: #selector(MainViewController.profilePressed(_:)))
        self.navigationItem.leftBarButtonItem = profile
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.distanceFilter = 200
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
        googleMap = GMSMapView.mapWithFrame(CGRect(x: 0,y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), camera: nil)
        self.view.addSubview(googleMap!)
        centerMap()
        
       
        
        
        
        lastLocation = locationManager?.location
        Brain.sharedBrain().lastLocation = lastLocation
    

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Brain.sharedBrain().currentEvent != nil){
            let nav = NavigationView(frame: CGRect(x: 0,y: 64,width: self.view.bounds.size.width,height: 80))
            self.view.addSubview(nav)
            nav.tag = kNavigationViewTag
            
            let confirmButton = UIButton(frame: CGRect(x: 0,y: self.view.bounds.size.height-60,width: self.view.bounds.size.width,height: 60))
            if(Brain.sharedBrain().currentEvent?.type == "pick"){
                confirmButton.setTitle("CONFIRMAR RETIRADO", for: UIControlState())
            }
            else{
                confirmButton.setTitle("CONFIRMAR ENTREGADO", for: UIControlState())
            }
            
            confirmButton.contentHorizontalAlignment = .center
            confirmButton.contentVerticalAlignment = .center
            confirmButton.backgroundColor = BLUE_COLOR
            confirmButton.setTitleColor(UIColor.white, for: UIControlState())
            confirmButton.tag = kConfirmButton
            confirmButton.addTarget(self, action: #selector(MainViewController.confirmPressed), for: .touchUpInside)
            self.view.addSubview(confirmButton)
            
            //self.navigationItem.rightBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MainViewController.cancelEvent(_:)))
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.getGoogleInformationRoute()
            
           let messagesButton = UIButton(frame: CGRect(x: self.view.bounds.size.width-60,y: self.view.bounds.size.height-120,width: 60,height: 60))
            
            messagesButton.setImage(UIImage(named: "message-icon.png"), for: UIControlState())
            messagesButton.addTarget(self, action: #selector(MainViewController.openMessages(_:)), for: .touchUpInside)
            
            messagesButton.tag = kMessageButtonTag
            
            self.view.addSubview(messagesButton)

            
            
        }
    }
    
    func openMessages(_ sender:AnyObject){
        let mess = MessagesViewController()
        self.navigationController?.pushViewController(mess, animated: true)
    }
    
    func cancelEvent(_ sender:AnyObject){
        
        let alertController = UIAlertController(title: "Cancelar", message: "¿Estás seguro de querer cancelar?", preferredStyle: .alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "SI", style: .default) { (action) -> Void in
            SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
            SwiftSpinner.show("Conectando...")
            let  url = "\(Brain.sharedBrain().serverIp!)/api/call/cancelEvent"
            
            let request = NSMutableURLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
            let data = postString.data(using: String.Encoding.utf8)
            let length = CUnsignedLong((data?.count)!)
            request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                
                SwiftSpinner.hide()
                
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
                
                let mensaje = "Has cancelado tu registro"
                let titulo = "Confirmación"
                
                
                
                
                
                
                
                DispatchQueue.main.async(execute: {
                    
                    
                    let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
                    
                    // Initialize Actions
                    let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                        
                        self.view.viewWithTag(self.kNavigationViewTag)?.removeFromSuperview()
                        self.view.viewWithTag(self.kConfirmButton)?.removeFromSuperview()
                        self.view.viewWithTag(self.kMessageButtonTag)?.removeFromSuperview()
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        //TODOOOOOOO
                        let plus =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.servicePressed(_:)))
                        self.navigationItem.rightBarButtonItem = plus
                        self.navigationItem.leftBarButtonItem?.isEnabled = true
                        self.polylineLoaded = false
                        Brain.sharedBrain().currentEvent = nil
                        self.googleMap?.clear()
                        self.driverMarker?.map = self.googleMap
                        Brain.sharedBrain().save()
                        
                        
                    }
                    
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                    
                })
                
            }) 
            task.resume()
            
        }
        
        let noAction = UIAlertAction(title: "NO", style: .cancel)  {(action) -> Void in
        
        };
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)

        
        
        
       

    }
    
    func centerMap(){
        if(CLLocationManager.locationServicesEnabled()){
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            
            
            let camera = GMSCameraPosition.cameraWithLatitude((locationManager?.location?.coordinate.latitude)!,
                longitude: (locationManager?.location?.coordinate.longitude)!, zoom: 15)
                googleMap?.camera = camera
            googleMap!.myLocationEnabled = false
                
            driverMarker = GMSMarker(position: CLLocationCoordinate2DMake((locationManager?.location?.coordinate.latitude)!,(locationManager?.location?.coordinate.longitude)!))
                driverMarker?.icon = UIImage(named: "truck_icon.png")
                driverMarker?.map = googleMap
                driverMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5);
                //locationManager?.startUpdatingHeading()
                
                locationManager?.startUpdatingLocation()

            }
            
            
            
            
        }
        else{
            let alertController = UIAlertController(
                title: "Servicios de localización desactivados",
                message: "Para poder utilizar la aplicación, debes habilitar los servicios de localización",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel ){(action) in
                
            }
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Preferencias", style: .default) { (action) in
                if let url = URL(string: "prefs:root=LOCATION_SERVICES") {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedAlways){
            centerMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        if(newHeading.headingAccuracy<0){
            return;
        }
        
        let h = ((newHeading.trueHeading > 0) ?
            newHeading.trueHeading : newHeading.magneticHeading);
        
        self.lastHeading = h
        driverMarker?.rotation = self.lastHeading
        NSLog("Changing heading to %f",self.lastHeading)
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        

        if(lastLocation == nil){
            lastLocation = location
            Brain.sharedBrain().lastLocation = lastLocation
        }
        else{
            if(lastLocation?.distanceFromLocation(location!)<1000){
                return;
            }
        }
        
        self.lastHeading = (location?.course)!
        self.lastLocation = location
        Brain.sharedBrain().lastLocation = lastLocation
        driverMarker?.rotation = self.lastHeading
        NSLog("Changing heading to %f",self.lastHeading)
        NSLog("latitude %+.6f, longitude %+.6f\n",
            location!.coordinate.latitude,
            location!.coordinate.longitude);
        if(UIApplication.shared.applicationState == .active){
        driverMarker?.position = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        
            let camera = GMSCameraPosition.cameraWithLatitude((locationManager?.location?.coordinate.latitude)!,
                                                          longitude: (locationManager?.location?.coordinate.longitude)!, zoom: 15)
        
            googleMap?.camera = camera
        }
        if(Brain.sharedBrain().currentEvent != nil&&polylineLoaded){
            sendLocationUpdatesToServer((location?.coordinate)!, heading: self.lastHeading)
        }
        
    }
    
    func servicePressed(_ sender:AnyObject){
        self.present(EventRegisterController(), animated: true, completion: nil)
    }
    
    func profilePressed(_ sender:AnyObject){
        
        self.present(ProfileViewController(), animated: true, completion: nil)
    }
    
    
    func sendLocationUpdatesToServer(_ posicion:CLLocationCoordinate2D,heading:Double){
        
        
        let timeLeft = calculateETA()
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/updatePosition")!)
        request.httpMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&lat=\(posicion.latitude)&lng=\(posicion.longitude)&heading=\(heading)&eta=\(timeLeft)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(String.Encoding.utf8)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
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
        }) 
        task.resume()
    }
    
    func confirmPressed(){
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
        SwiftSpinner.show("Conectando...")
        var url = ""
        if(Brain.sharedBrain().currentEvent?.type == "pick"){
            if(Brain.sharedBrain().currentEvent?.secondConfirmation == true){
                url = "\(Brain.sharedBrain().serverIp!)/api/call/finishEventPickup"
            }
            else{
                url = "\(Brain.sharedBrain().serverIp!)/api/call/eventPickedUp"
            }
        }
        else{
            url = "\(Brain.sharedBrain().serverIp!)/api/call/finishEventDeliver"
        }
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            SwiftSpinner.hide()
            
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            
                var mensaje = ""
                let titulo = "Confirmación"
                print(Brain.sharedBrain().currentEvent?.trailer)
                print(Brain.sharedBrain().currentEvent?.type)
            
                if(Brain.sharedBrain().currentEvent?.type == "pick"){
                    if(Brain.sharedBrain().currentEvent?.secondConfirmation == false){
                        mensaje = "Has confirmado haber retirado el contenedor con booking \((Brain.sharedBrain().currentEvent?.trailer)!)."
                    }
                    else{
                        mensaje = "Has confirmado haber entregado al destinatario el contenedor con booking \((Brain.sharedBrain().currentEvent?.trailer)!)."
                    }
                    
                    
                }
                else{
                    let e = Brain.sharedBrain().currentEvent
                    if(Brain.sharedBrain().currentEvent?.segundo != nil){
                        
                        mensaje = "Has confirmado la entrega de los contenedores \((e?.trailer)!) y \((e?.segundo)!)"
                    }
                    else{
                        mensaje = "Has confirmado la entrega del contenedor \((e?.trailer)!)"
                    }
                }
            
            let type = Brain.sharedBrain().currentEvent?.type;
            DispatchQueue.main.async(execute: {
               

                let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
                
                // Initialize Actions
                let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    if(type == "pick"){
                        if(Brain.sharedBrain().currentEvent?.secondConfirmation == true){
                            self.view.viewWithTag(self.kNavigationViewTag)?.removeFromSuperview()
                            self.view.viewWithTag(self.kConfirmButton)?.removeFromSuperview()
                           

                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            let plus =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.servicePressed(_:)))
                            self.navigationItem.rightBarButtonItem = plus
                            self.navigationItem.leftBarButtonItem?.isEnabled = true
                            self.polylineLoaded = false
                            Brain.sharedBrain().currentEvent = nil
                            Brain.sharedBrain().save()
                            
                        }
                        else{
                            (self.view.viewWithTag(self.kConfirmButton) as!UIButton).setTitle("CONFIRMAR ENTREGA", for: UIControlState())
                            self.view.viewWithTag(self.kNavigationViewTag)?.removeFromSuperview()
                            self.view.viewWithTag(self.kMessageButtonTag)?.removeFromSuperview()
                            self.googleMap?.clear()
                            self.driverMarker?.map = self.googleMap
                            Brain.sharedBrain().currentEvent?.secondConfirmation = true
                            Brain.sharedBrain().save()
                        }
                    }
                    else{
                        self.view.viewWithTag(self.kNavigationViewTag)?.removeFromSuperview()
                        self.view.viewWithTag(self.kConfirmButton)?.removeFromSuperview()
                        self.view.viewWithTag(self.kMessageButtonTag)?.removeFromSuperview()

                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        let plus =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.servicePressed(_:)))
                        self.navigationItem.rightBarButtonItem = plus
                        self.navigationItem.leftBarButtonItem?.isEnabled = true
                        self.googleMap?.clear()
                        self.driverMarker?.map = self.googleMap
                        
                        self.polylineLoaded = false
                        Brain.sharedBrain().currentEvent = nil
                        Brain.sharedBrain().save()

                    }
                    
                }
                
                alertController.addAction(yesAction)
                self.present(alertController, animated: true, completion: nil)
                
                
                
                
            })
            
        }) 
        task.resume()
    }
    
    func getGoogleInformationRoute(){
        
        
        if(Brain.sharedBrain().currentEvent?.polyline == nil){
           
        if(lastLocation == nil){
            return;
        }
            
            SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
            SwiftSpinner.show("Actualizando...")
        
        let origin = "\((lastLocation?.coordinate.latitude)!),\((lastLocation?.coordinate.longitude)!)"
        let request = NSMutableURLRequest(URL: URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\((Brain.sharedBrain().currentEvent?.destino)!)")!)
        request.HTTPMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let task = URLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            SwiftSpinner.hide()
            
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            
            if let httpStatus = response as? NSHTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString!)")
            
            let dict = self.convertStringToDictionary(responseString! as String)
            let overview = ((dict?.objectForKey("routes") as? NSArray)![0].objectForKey("overview_polyline") as? NSDictionary)?.objectForKey("points") as? String
            Brain.sharedBrain().currentEvent?.polyline = overview
            Brain.sharedBrain().save()
            let pol = GMSPolyline(path: GMSPath(fromEncodedPath: overview))
            pol.strokeWidth = 2;
            pol.map = self.googleMap;
            self.polylineLoaded = true
            self.sendLocationUpdatesToServer(self.lastLocation!.coordinate, heading: self.lastHeading)
           
        }
        task.resume()
        }
        else{
            let overview = Brain.sharedBrain().currentEvent?.polyline
            let pol = GMSPolyline(path: GMSPath(fromEncodedPath: overview))
            pol.strokeWidth = 2;
            
            pol.map = self.googleMap;
            self.sendLocationUpdatesToServer(self.lastLocation!.coordinate, heading: self.lastHeading)

        }
    }
    
    func convertStringToDictionary(_ text: String) -> NSDictionary? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    func calculateETA() -> Double{
        let path = GMSPath(fromEncodedPath: Brain.sharedBrain().currentEvent!.polyline)
        var totalDistance = 0.0
        
        let startIndex = self.getClosestIndexPointToPath(path, location: lastLocation!)
        print(startIndex)
        for var i in UInt(startIndex+1)...(path.count()-1) {
            let location1 = path.coordinateAtIndex(i-1)
            let location2 = path.coordinateAtIndex(i)
            totalDistance = totalDistance + distance(location1, to: location2) as Double
        }
        
        totalDistance = totalDistance/1000;
        
        var timeLeft = totalDistance/40;
        timeLeft = timeLeft * 60*60;
        
        
        
        print(totalDistance)
        return timeLeft
        
    }
    
    func distance(_ from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        let _from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let _to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return _from.distanceFromLocation(_to)
    }
    
    
    func getClosestIndexPointToPath(_ path: GMSPath,location:CLLocation) -> Int{
        var idx = -1;
        var minDistance = DBL_MAX;
        
        for var i in 0...path.count()-1{
            let temp = path.coordinateAtIndex(i)
            let dist = distance(location.coordinate, to: temp) as Double?
            if (dist < minDistance){
                minDistance = dist!
                idx = Int(i);
            }
            
        }
        
        return idx;
        
    }
    
    
    
}
