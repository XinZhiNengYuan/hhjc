//
//  DailyNearlyCollectionViewCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/25.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DailyNearlyCollectionViewCell: UICollectionViewCell {
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    func creatUI(){
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.layer.cornerRadius = 10
        
        
        self.label = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth-20, height: 15))
        //        label.tintColor =
        label.textColor = UIColor.white
        label.alpha = 0.5951
        self.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
