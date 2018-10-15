//
//  UIBarButtonItem+badge.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/13.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class UIBarButtonItem_badge: UIBarButtonItem {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    public func addMessage(msg:String){
        let rightBarButton:UIButton = UIButton.init()
        rightBarButton.setImage(UIImage(named: "报警"), for: UIControlState.normal)
        rightBarButton.tintColor = UIColor.white
        
        let msgView:UIButton = UIButton.init(frame: CGRect(x: 12.5, y: 0, width: 15, height: 15))
        msgView.backgroundColor = UIColor.red
        msgView.layer.cornerRadius = 5
        msgView.setTitle(msg, for: UIControlState.normal)
        msgView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        msgView.tintColor = UIColor.white
        rightBarButton.addSubview(msgView)
        self.customView = rightBarButton
    }
    public func removeMessage(msg:String){
        let rightBarButton:UIButton = UIButton.init()
        rightBarButton.setImage(UIImage(named: "报警"), for: UIControlState.normal)
        rightBarButton.tintColor = UIColor.white
        
//        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(customView: rightBarButton)
        self.customView = rightBarButton
    }
}

