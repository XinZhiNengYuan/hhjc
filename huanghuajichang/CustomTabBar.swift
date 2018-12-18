//
//  CustomTabBar.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/18.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for tabBarButton in subviews {
            if NSStringFromClass(tabBarButton.classForCoder) == "UITabBarButton"{
                let ctr = tabBarButton as! UIControl
                ctr.addTarget(self,
                              action: #selector(self.barButtonActin(sender:)),
                              for: UIControlEvents.touchUpInside)
            }
        }
    }
    @objc func barButtonActin(sender:UIControl)  {
//        print(sender.subviews)
        
        for imageView in sender.subviews {
            if NSStringFromClass(imageView.classForCoder) == "UITabBarSwappableImageView"{
                self.tabBarAnimationWithView(view: imageView)
            }
        }
    }
    
    @objc func tabBarAnimationWithView(view:UIView){
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [1.0,1.3,1.5,1.25,0.8,1.25,1.0]
        scaleAnimation.duration = 0.5
        scaleAnimation.calculationMode = kCAAnimationCubic
        scaleAnimation.repeatCount = 1
        view.layer.add(scaleAnimation, forKey: "123")
    }
}
