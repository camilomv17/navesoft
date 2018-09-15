//
//  SearchPatioViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 8/30/18.
//  Copyright © 2018 Camilo Mariño. All rights reserved.
//

import Foundation

import UIKit

class SearchPatioViewController:UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating{
    
    var tableView:UITableView?
    var data = [String]()
    var searchData = [String]()
    var displayController:UISearchController?
    var shouldShowSearchResults = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0,y: 0,width: self.view.bounds.size.width,height: 64))
        navigationBar.backgroundColor = UIColor.white
        let navigationItem = UINavigationItem()
        navigationItem.title = "PATIOS"
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SearchViewController.donePressed))
        navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SearchViewController.cancelPressed))
        
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        
        tableView = UITableView(frame: CGRect(x: 0,y: 64,width: self.view.bounds.size.width,height: self.view.bounds.size.height-64),style: .plain)
        displayController = UISearchController(searchResultsController: nil)
        displayController?.searchResultsUpdater = self
        displayController?.dimsBackgroundDuringPresentation = false
        displayController?.searchBar.placeholder = "Buscar..."
        displayController?.searchBar.delegate = self
        displayController?.searchBar.sizeToFit()
        tableView?.tableHeaderView = displayController?.searchBar
        tableView?.dataSource = self
        tableView?.delegate = self
        self.view.addSubview(tableView!)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
        
    }
    
    func fetchData(){
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
        SwiftSpinner.show("Conectando...")
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getPatiosCiudad")!)
        request.httpMethod = "POST"
        let postString = "ciudad=BAQ";
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
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
            print("responseString = \(responseString)")
            
            var error:NSError?
            let newData = NSMutableArray()
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                for element in json {
                    let dict = element as! NSDictionary
                    let name = dict.object(forKey: "name") as! String
                    newData.add(name)
                    
                }
                
                self.data = NSArray(array:newData) as! [String]
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                });
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        })
        task.resume()
    }
    
    
    func donePressed(){
        displayController?.searchBar.resignFirstResponder()
        if( self.presentingViewController is UINavigationController){
            let  controllers = (self.presentingViewController as! UINavigationController).viewControllers as NSArray
            
            let parent = controllers.lastObject as! RegisterViewController
            self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected((self.displayController?.searchBar.text)!)})
        }
        else{
            let parent = self.presentingViewController as! ProfileViewController
            self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected((self.displayController?.searchBar.text)!)})
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(self.presentingViewController is UINavigationController){
            let  controllers = (self.presentingViewController as! UINavigationController).viewControllers as NSArray
            if(shouldShowSearchResults){
                let text = searchData[indexPath.row]
                let parent = controllers.lastObject as! RegisterViewController
                
                self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected(text)})
                
            }
            else{
                let text = data[indexPath.row]
                let parent = controllers.lastObject as! RegisterViewController
                
                self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected(text)})
            }
        }
        else{
            if(shouldShowSearchResults){
                let text = searchData[indexPath.row]
                let parent = self.presentingViewController as! ProfileViewController
                
                self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected(text)})
                
            }
            else{
                let text = data[indexPath.row]
                let parent = self.presentingViewController as! ProfileViewController
                
                self.presentingViewController?.dismiss(animated: true, completion: {() in parent.setCompanySelected(text)})
            }
        }
    }
    
    func cancelPressed(){
        displayController?.searchBar.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
            return (searchData.count)
        }
        else{
            return (data.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView!.dequeueReusableCell(withIdentifier: "cell")
        if(cell==nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        
        if shouldShowSearchResults {
            cell!.textLabel?.text = searchData[indexPath.row] as? String
        }
        else {
            cell!.textLabel?.text = data[indexPath.row] as? String
        }
        
        return cell!
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView?.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView?.reloadData()
        }
        
        displayController?.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        print("UPDATING")
        // Filter the data array and get only those countries that match the search text.
        searchData = data.filter({ (e) -> Bool in
            let eText: NSString = e as NSString
            
            return (eText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        tableView!.reloadData()
}

}
