//
//  DataPickerView.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/26/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

protocol DataPickerDelegate{
    func returnValues(value:String)
}

class DataPickerView:UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    public var opacityView:UIView?
    public var dialogView:UIView?
    var title:String?
    var data:NSArray?
    var picker:UIPickerView?
    var actualRow = 0
    var delegate:DataPickerDelegate?
     init(frame: CGRect,data:NSArray,title:String) {
        super.init(frame: frame)
        self.title = title
        self.data = data
        opacityView = UIView(frame: self.bounds)
        opacityView!.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        opacityView!.layer.opacity = 0.0
        opacityView!.backgroundColor = UIColor.blackColor()
        
        self.insertSubview(opacityView!, atIndex: 1)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(DataPickerView.dissapear))
        
        opacityView?.addGestureRecognizer(t)
        
        dialogView = UIView(frame: CGRectMake(0,self.bounds.size.height,self.bounds.size.width,220))
        
        dialogView?.backgroundColor = UIColor.whiteColor()
        dialogView?.layer.opacity = 1
        dialogView?.layer.cornerRadius = 3;
        dialogView?.backgroundColor = UIColor.whiteColor()
        self.insertSubview(dialogView!, atIndex: 2);
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0,0,self.bounds.size.width,44))
        navigationBar.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        let navigationItem = UINavigationItem()
        navigationItem.title = self.title
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(DataPickerView.donePressed))
        rightButton.tintColor = BLUE_COLOR
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        dialogView!.addSubview(navigationBar)
        
        picker = UIPickerView(frame: CGRectMake(0,44,self.bounds.size.width,162))
        picker?.dataSource = self
        picker?.delegate = self
        dialogView?.addSubview(picker!)

        
        

        
    }
    
    func donePressed(){
        let string = data![actualRow] as? String
        delegate?.returnValues(string!)
        dissapear()
    }
    
    
    
    
    func appear(){
        UIApplication.sharedApplication().delegate?.window!!.addSubview(self)
        
        
        UIView.animateWithDuration(Double(0.2), delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.opacityView?.layer.opacity = 0.5
                strongSelf.dialogView?.frame = CGRectMake(0,strongSelf.bounds.size.height - 220,strongSelf.bounds.size.width,220)
                
            }
            },completion: {[weak self](Bool) -> Void in
                if let strongSelf = self{
                    
                }
            }
        )
    }
    
    func dissapear(){
        
        UIView.animateWithDuration(Double(0.2), delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.opacityView?.layer.opacity = 0.0
                strongSelf.dialogView?.frame = CGRectMake(0,strongSelf.bounds.size.height,strongSelf.bounds.size.width,220)
                
            }
            },completion: {[weak self](Bool) -> Void in
                if let strongSelf = self{
                    strongSelf.removeFromSuperview()
                }
            }
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data![row] as! String
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selectedRow")
        actualRow = row
        print(actualRow)
    }
}
