//
//  RealTimeReusableView.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/28.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class RealTimeReusableView: UICollectionReusableView {
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label = UILabel(frame: CGRect(x: 10, y: 5, width: kSCREEN_WIDTH-20, height: 20))
//        label.tintColor =
//        label.textColor = allFontColor
//        label.alpha = 0.5951
        self.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
