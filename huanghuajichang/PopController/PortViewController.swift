//
//  PortViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/9.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PortViewController: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:构建自定义弹框样式
    class func creatAlertView() -> UIView{
        let contentView  = UIView()
        let Screen_w = UIScreen.main.bounds.size.width
        let Screen_h = UIScreen.main.bounds.size.height
        
        contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        contentView.frame.origin.x = Screen_w/2
        contentView.frame.origin.y = Screen_h/2
        contentView.bounds = CGRect(x: 0, y: 0, width: 200, height: 120)
        contentView.layer.cornerRadius = 10
        return contentView
    }

}
