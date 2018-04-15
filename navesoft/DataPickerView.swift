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
    func returnValues(_ value:String)
}

class DataPickerView:UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    open var opacityView:UIView?
    open var dialogView:UIView?
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
        opacityView!.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        opacityView!.layer.opacity = 0.0
        opacityView!.backgroundColor = UIColor.black
        
        self.insertSubview(opacityView!, at: 1)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(DataPickerView.dissapear))
        
        opacityView?.addGestureRecognizer(t)
        
        dialogView = UIView(frame: CGRect(x: 0,y: self.bounds.size.height,width: self.bounds.size.width,height: 220))
        
        dialogView?.backgroundColor = UIColor.white
        dialogView?.layer.opacity = 1
        dialogView?.layer.cornerRadius = 3;
        dialogView?.backgroundColor = UIColor.white
        self.insertSubview(dialogView!, at: 2);
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0,y: 0,width: self.bounds.size.width,height: 44))
        navigationBar.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        let navigationItem = UINavigationItem()
        navigationItem.title = self.title
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DataPickerView.donePressed))
        rightButton.tintColor = BLUE_COLOR
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        dialogView!.addSubview(navigationBar)
        
        picker = UIPickerView(frame: CGRect(x: 0,y: 44,width: self.bounds.size.width,height: 162))
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
        UIApplication.shared.delegate?.window!!.addSubview(self)
        
        
        UIView.animate(withDuration: Double(0.2), delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.opacityView?.layer.opacity = 0.5
                strongSelf.dialogView?.frame = CGRect(x: 0,y: strongSelf.bounds.size.height - 220,width: strongSelf.bounds.size.width,height: 220)
                
            }
            },completion: {[weak self](Bool) -> Void in
                if let strongSelf = self{
                    
                }
            }
        )
    }
    
    func dissapear(){
        
        UIView.animate(withDuration: Double(0.2), delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.opacityView?.layer.opacity = 0.0
                strongSelf.dialogView?.frame = CGRect(x: 0,y: strongSelf.bounds.size.height,width: strongSelf.bounds.size.width,height: 220)
                
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data![row] as! String
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selectedRow")
        actualRow = row
        print(actualRow)
    }
}
