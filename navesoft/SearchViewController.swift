//
//  SearchViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/26/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController:UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating{
    
    var tableView:UITableView?
    var data = [String]()
    var searchData = [String]()
    var displayController:UISearchController?
    var shouldShowSearchResults = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0,0,self.view.bounds.size.width,64))
        navigationBar.backgroundColor = UIColor.whiteColor()
        let navigationItem = UINavigationItem()
        navigationItem.title = "EMPRESAS"
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SearchViewController.donePressed))
        navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SearchViewController.cancelPressed))
        
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        
        tableView = UITableView(frame: CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height-64),style: .Plain)
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
    
    override func viewDidAppear(animated: Bool) {
        fetchData()
        
    }
    
    func fetchData(){
            SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
            SwiftSpinner.show("Conectando...")
            let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getCompanies")!)
            request.HTTPMethod = "POST"
        
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                
                SwiftSpinner.hide()
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
                
                var error:NSError?
                let newData = NSMutableArray()
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSArray
                    for element in json {
                        let dict = element as! NSDictionary
                        let name = dict.objectForKey("name") as! String
                        newData.addObject(name)
                        
                    }
                    
                    self.data = NSArray(array:newData) as! [String]
                    dispatch_async(dispatch_get_main_queue(),{
                        self.tableView?.reloadData()
                    });
                    
                    SwiftSpinner.hide()
                    
                }
                catch{
                    print("FFUUUUUU")
                }
            }
            task.resume()
        }
    
    
    func donePressed(){
        displayController?.searchBar.resignFirstResponder()
        if( self.presentingViewController is UINavigationController){
            let  controllers = (self.presentingViewController as! UINavigationController).viewControllers as NSArray
        
            let parent = controllers.lastObject as! RegisterViewController
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected((self.displayController?.searchBar.text)!)})
        }
        else{
            let parent = self.presentingViewController as! ProfileViewController
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected((self.displayController?.searchBar.text)!)})
        }
       
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(self.presentingViewController is UINavigationController){
        let  controllers = (self.presentingViewController as! UINavigationController).viewControllers as NSArray
        if(shouldShowSearchResults){
            let text = searchData[indexPath.row]
            let parent = controllers.lastObject as! RegisterViewController
            
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected(text)})
            
        }
        else{
            let text = data[indexPath.row]
            let parent = controllers.lastObject as! RegisterViewController
            
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected(text)})
        }
        }
        else{
            if(shouldShowSearchResults){
                let text = searchData[indexPath.row]
                let parent = self.presentingViewController as! ProfileViewController
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected(text)})
                
            }
            else{
                let text = data[indexPath.row]
                 let parent = self.presentingViewController as! ProfileViewController
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: {() in parent.setCompanySelected(text)})
            }
        }
    }
    
    func cancelPressed(){
        displayController?.searchBar.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
        return (searchData.count)
        }
        else{
            return (data.count)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView!.dequeueReusableCellWithIdentifier("cell")
        if(cell==nil){
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }

        
        if shouldShowSearchResults {
            cell!.textLabel?.text = searchData[indexPath.row] as? String
        }
        else {
            cell!.textLabel?.text = data[indexPath.row] as? String
        }
        
        return cell!
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView?.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView?.reloadData()
        }
        
        displayController?.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        print("UPDATING")
        // Filter the data array and get only those countries that match the search text.
        searchData = data.filter({ (e) -> Bool in
            let eText: NSString = e
            
            return (eText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableview.
        tableView!.reloadData()
    }
    
}
