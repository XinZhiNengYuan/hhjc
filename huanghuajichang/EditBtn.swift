//
//  EditBtn.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/10.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class EditBtn: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        if view == nil {
            for subView in self.subviews.enumerated(){
                let tp = subView.element.convert(point, from: self)
                if (subView.element.point(inside: tp, with: event)) {
                    return subView.element
                }
            }
        }
        return view
    }
    

}
