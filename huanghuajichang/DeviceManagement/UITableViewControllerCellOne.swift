//
//  UITableViewControllerCellOne.swift
//  buttonDemo
//  一级菜单
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 zx. All rights reserved.
//

import UIKit

class UITableViewControllerCellOne: UIView,UIGestureRecognizerDelegate {
    let mLabel : UILabel = UILabel()
    let mView : UIView = UIView()
    let rectPath = UIBezierPath()
    var isSelected : Bool = false
    let areShapeLayer = CAShapeLayer()
    let rectShapeLayer = CAShapeLayer()
    var callBack = {(index : Int,isSelected : Bool)->Void in
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        mView.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width, height: 35)
        mLabel.frame = CGRect(x: 30, y: 0, width: mView.frame.width*1/3, height: mView.frame.height)
        mLabel.font = UIFont.boldSystemFont(ofSize: 14)
        mLabel.textColor = UIColor.white
        mLabel.layer.borderColor = UIColor(red: 64/255, green: 155/255, blue: 239/255, alpha: 1).cgColor
        mLabel.layer.borderWidth = 1
        mLabel.layer.cornerRadius = 5
        mLabel.layer.backgroundColor = UIColor(red: 64/255, green: 155/255, blue: 239/255, alpha: 1).cgColor
        mLabel.textAlignment = .center
        
        
        /*
         参数解释：
         1.center: CGPoint  中心点坐标
         2.radius: CGFloat  半径
         3.startAngle: CGFloat 起始点所在弧度
         4.endAngle: CGFloat   结束点所在弧度
         5.clockwise: Bool     是否顺时针绘制
         7.画圆时，没有坐标这个概念，根据弧度来定位起始点和结束点位置。M_PI即是圆周率。画半圆即(0,M_PI),代表0到180度。全圆则是(0,M_PI*2)，代表0到360度
         */
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: 10, y: 15), radius: 5, startAngle: CGFloat(M_PI) * 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        areShapeLayer.path = arcPath.cgPath //存入UIBezierPath的路径
        areShapeLayer.fillColor = UIColor.blue.cgColor //设置填充色
        areShapeLayer.lineWidth = 2  //设置路径线的宽度
        areShapeLayer.strokeColor = UIColor.gray.cgColor //路径颜色
        //如果想变为虚线设置这个属性，[实线宽度，虚线宽度]，若两宽度相等可以简写为[宽度]
        areShapeLayer.lineDashPattern = [0]
        //一般可以填"path"  "strokeStart" "strokeEnd"  具体还需研究
//        let baseAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        baseAnimation.duration = 2   //持续时间
//        baseAnimation.fromValue = 0  //开始值
//        baseAnimation.toValue = 2    //结束值
//        baseAnimation.repeatDuration = 5  //重复次数
//        shapeLayer.addAnimation(baseAnimation, forKey: nil) //给ShapeLayer添
        //显示在界面上
        mView.layer.addSublayer(areShapeLayer)
        mView.addSubview(mLabel)
        self.addSubview(mView)
        let gestureOption = UITapGestureRecognizer()
        gestureOption.delegate = self
        gestureOption.isEnabled = true
        gestureOption.addTarget(self, action: #selector(touched))
        mView.addGestureRecognizer(gestureOption)
    }
    
    @objc func touched(){
        //setViewStatus()
        callBack(self.tag,isSelected)
    }
}
