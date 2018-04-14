//
//  NavigationView.swift
//  navesoft
//
//  Created by Camilo Mariño on 3/7/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

class NavigationView:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let destinoLabel = UILabel(frame: CGRectMake(10,10,self.bounds.size.width-80,20))
        destinoLabel.font = UIFont.systemFontOfSize(15)
        destinoLabel.text = "DESTINO: \((Brain.sharedBrain().currentEvent?.patio)!)"
        destinoLabel.textColor = UIColor.blackColor()
        
        self.addSubview(destinoLabel)
        
        let bookingLabel = UILabel(frame: CGRectMake(10,40,self.bounds.size.width-80,20))
        bookingLabel.font = UIFont.systemFontOfSize(15)
        if(Brain.sharedBrain().currentEvent?.type == "pick"){
            bookingLabel.text = "BOOKING: \((Brain.sharedBrain().currentEvent?.trailer)!)"
        }
        else{
            bookingLabel.text = "CONTENEDOR: \((Brain.sharedBrain().currentEvent?.trailer)!)"
        }
        bookingLabel.textColor = UIColor.blackColor()
        
        self.addSubview(bookingLabel)
        
        self.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.alpha = 0.85
        
        let navigateButton = UIButton(frame: CGRectMake(self.bounds.size.width-70,0,70,70))
        navigateButton.setImage(UIImage(named: "ic_navigateArrow.png"), forState: .Normal)
        navigateButton.contentHorizontalAlignment = .Center
        navigateButton.contentVerticalAlignment = .Center
        navigateButton.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.addSubview(navigateButton)
        navigateButton.addTarget(self, action: #selector(NavigationView.openWaze), forControlEvents: .TouchUpInside)
        
        let line = UIView(frame: CGRectMake(self.bounds.size.width-70,0,1,self.bounds.size.height))
        line.backgroundColor = BLUE_COLOR
        self.addSubview(line)
        
        let navLabel = UILabel(frame: CGRectMake(self.bounds.size.width-70,66,70,14))
        navLabel.text = "Navegar"
        navLabel.font = UIFont.systemFontOfSize(12)
        navLabel.textAlignment = .Center
        navLabel.textColor = BLUE_COLOR
        self.addSubview(navLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    
    
    func openWaze(){
        if(UIApplication.sharedApplication().canOpenURL(NSURL(string: "waze://")!)){
            print(Brain.sharedBrain().currentEvent?.destino)
            
            let url = "waze://?ll=\((Brain.sharedBrain().currentEvent?.destino)!)&navigate=yes"
            print(url)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
        else{
            
        }
    }
}