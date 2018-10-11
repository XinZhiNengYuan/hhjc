//
//  BasePopView.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/10.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class BasePopView: UIView {

    /// 添加Alert入场动画
    ///
    /// - Parameter alert: 添加动画的View
    func show(withAlert alert: UIView?) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = CFTimeInterval(0.3)
        var values = [AnyHashable]()
        values.append(NSValue(caTransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0)))
        values.append(NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)))
        values.append(NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)))
        values.append(NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animation.values = values
        alert?.layer.add(animation, forKey: nil)
    }
    

}
