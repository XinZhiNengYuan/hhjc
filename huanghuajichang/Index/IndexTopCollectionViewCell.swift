//
//  IndexTopCollectionViewCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/11.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class IndexTopCollectionViewCell: UICollectionViewCell {
    var label:UILabel!
    var unitLabel:UILabel!
    var value:UILabel!
    var secondView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(textColors:[UIColor], cellBackGroundColor:UIColor, title:String){
        self.backgroundColor = cellBackGroundColor
        
        self.value = UILabel(frame: CGRect(x: 0, y: 15, width: self.frame.width, height: 20))
        value.textColor = textColors[0]
        value.textAlignment = .center
        value.font = UIFont.init(name: "PingFangSC-Regular", size: 19.6)
        self.addSubview(self.value)
        
        self.label = UILabel(frame: CGRect(x: (self.frame.width - CGFloat(title.count*(80/6)) - 30)/2, y: 40, width: CGFloat(title.count*(80/6)), height: 20))
        label.textColor = textColors[1]
        label.textAlignment = .center
        label.font = UIFont.init(name: "PingFangSC-Regular", size: 12.1)
        //        label.adjustsFontSizeToFitWidth = true
        self.addSubview(self.label)
        
        self.unitLabel = UILabel(frame: CGRect(x: self.label.frame.width+self.label.frame.origin.x, y: 40, width: 30, height: 20))
        unitLabel.textColor = textColors[2]
        unitLabel.textAlignment = .center
        unitLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 12.1)
        self.addSubview(self.unitLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
