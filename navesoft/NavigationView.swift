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
        
        let destinoLabel = UILabel(frame: CGRect(x: 10,y: 10,width: self.bounds.size.width-80,height: 20))
        destinoLabel.font = UIFont.systemFont(ofSize: 15)
        destinoLabel.text = "DESTINO: \((Brain.sharedBrain().currentEvent?.patio)!)"
        destinoLabel.textColor = UIColor.black
        
        self.addSubview(destinoLabel)
        
        let bookingLabel = UILabel(frame: CGRect(x: 10,y: 40,width: self.bounds.size.width-80,height: 20))
        bookingLabel.font = UIFont.systemFont(ofSize: 15)
        if(Brain.sharedBrain().currentEvent?.type == "pick"){
            bookingLabel.text = "BOOKING: \((Brain.sharedBrain().currentEvent?.trailer)!)"
        }
        else{
            bookingLabel.text = "CONTENEDOR: \((Brain.sharedBrain().currentEvent?.trailer)!)"
        }
        bookingLabel.textColor = UIColor.black
        
        self.addSubview(bookingLabel)
        
        self.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.alpha = 0.85
        
        let navigateButton = UIButton(frame: CGRect(x: self.bounds.size.width-70,y: 0,width: 70,height: 70))
        navigateButton.setImage(UIImage(named: "ic_navigateArrow.png"), for: UIControlState())
        navigateButton.contentHorizontalAlignment = .center
        navigateButton.contentVerticalAlignment = .center
        navigateButton.backgroundColor = ULTRA_LIGHT_GRAY_COLOR
        self.addSubview(navigateButton)
        navigateButton.addTarget(self, action: #selector(NavigationView.openWaze), for: .touchUpInside)
        
        let line = UIView(frame: CGRect(x: self.bounds.size.width-70,y: 0,width: 1,height: self.bounds.size.height))
        line.backgroundColor = BLUE_COLOR
        self.addSubview(line)
        
        let navLabel = UILabel(frame: CGRect(x: self.bounds.size.width-70,y: 66,width: 70,height: 14))
        navLabel.text = "Navegar"
        navLabel.font = UIFont.systemFont(ofSize: 12)
        navLabel.textAlignment = .center
        navLabel.textColor = BLUE_COLOR
        self.addSubview(navLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    
    
    func openWaze(){
        if(UIApplication.shared.canOpenURL(URL(string: "waze://")!)){
            print(Brain.sharedBrain().currentEvent?.destino)
            
            let url = "waze://?ll=\((Brain.sharedBrain().currentEvent?.destino)!)&navigate=yes"
            print(url)
            UIApplication.shared.openURL(URL(string: url)!)
        }
        else{
            
        }
    }
}
