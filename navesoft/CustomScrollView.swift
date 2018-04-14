//
//  CustomScrollView.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/26/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit

class CustomScrollView:UIScrollView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
    }
}