//
//  ThickButton.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/18.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class ThickButton: NSObject {
    
    // button数组
    var buttonArr:NSMutableArray = []
    
    //声明协议
    weak open var delegate: ThickButtonDelagate?
    
    //滑块
    var sliderView:UIView!
    var moveWidth:CGFloat = 0.0
    
    
    
    
    // 创建view方法
    func creatThickButton(buttonsFrame:CGRect, dataArr:[ThickButtonModel]) ->UIView {
        // 最底层容器view
        let myView = UIView(frame: buttonsFrame)
        
        // 计算按钮大小
        let gap = 10
        let btnWidth = (myView.frame.width - CGFloat(gap*(dataArr.count-1)))/CGFloat(dataArr.count)
        moveWidth = btnWidth
        for index in 0..<dataArr.count {
            // 定义button
            let tabBtn = UIButton.init(frame:CGRect(x:CGFloat(index)*(10.0+btnWidth), y:0, width:btnWidth, height:62))
            // 赋值
//            tabBtn.setTitle(dataArr[index] as? String, for: UIControlState.normal)
//            tabBtn.backgroundColor = UIColor.black
//            tabBtn.titleLabel?.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
//            tabBtn.setTitleColor(UIColor.init(red:51/255,green:51/255,blue:51/255,alpha:1), for: UIControlState.normal)
//            tabBtn.setTitleColor(UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1), for: UIControlState.selected)
//            tabBtn.layer.borderWidth=1
//            tabBtn.layer.cornerRadius = 20
            
            let valueLabel = UILabel.init()
            valueLabel.frame.size = CGSize(width: btnWidth, height: 25)
            valueLabel.font = UIFont(name: "PingFangSC-Regular", size: 25)
            valueLabel.center.x = 1/2*btnWidth
            valueLabel.frame.origin.y = 5
            valueLabel.textAlignment = .center
            valueLabel.text = "\(dataArr[index].value)"
            valueLabel.textColor = UIColor.lightGray
            valueLabel.tag = 1+index
            tabBtn.addSubview(valueLabel)
            
            let describeLabel = UILabel.init()
            describeLabel.frame.size = CGSize(width: btnWidth, height: 20)
            describeLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
            describeLabel.center.x = 1/2*btnWidth
            describeLabel.frame.origin.y = 35
            describeLabel.text = dataArr[index].describe
            describeLabel.textAlignment = .center
            describeLabel.tag = 2+index
            describeLabel.textColor = UIColor.lightGray
            tabBtn.addSubview(describeLabel)
            
            if index == 0 {
                tabBtn.isSelected = true
                valueLabel.textColor = topValueColor
                describeLabel.textColor = topValueColor
                //                tabBtn.backgroundColor = UIColor.init(red: 37/255, green: 44/255, blue: 61/255, alpha: 1)
            }
            tabBtn.tag = index
            // 同一个点击方法 根据传值和数组区分
            tabBtn.addTarget(self, action: #selector(buttonClick(button:)), for: UIControlEvents.touchUpInside)
            // 添加到view上
            myView.addSubview(tabBtn)
            // 加入button数组
            buttonArr.add(tabBtn)
        }
        
        //设置按钮下的滑块
        sliderView = UIView.init()
        sliderView.backgroundColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        sliderView.layer.cornerRadius = 2
        sliderView.clipsToBounds = true
        myView.addSubview(sliderView)
        sliderView.frame = CGRect(x: 0, y: 60, width: btnWidth, height: 2)
        
        
        // 返回值
        return myView
    }
    // 按钮点击事件
    @objc func buttonClick(button:UIButton){
        for b in buttonArr{
            // 遍历按钮数组,如果相同就改成选中状态,不相同就取消选中状态
            let childValue = (b as! UIButton).subviews[0] as! UILabel
            
            let childDescribe:UILabel = (b as! UIButton).subviews[1] as! UILabel
            if (b as! UIButton) == button{
                print("index+\(button.tag)")
                if (self.delegate?.responds(to: #selector(LineButtonDelagate.clickChangePage(_:buttonIndex:))))!{
                    self.delegate?.clickChangePage(self, buttonIndex: button.tag)
                }
                (b as! UIButton).isSelected = true
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.sliderView.center = CGPoint(x: CGFloat(button.tag)*(10+self.moveWidth)+self.sliderView.frame.width/2, y: 61)
                }, completion: { (finish) -> Void in
                    childValue.textColor = topValueColor
                    
                    childDescribe.textColor = topValueColor
                })
                //                (b as! UIButton).backgroundColor = UIColor.init(red: 37/255, green: 44/255, blue: 61/255, alpha: 1)
                
            }else{
                (b as! UIButton).isSelected = false
                childValue.textColor = allUnitColor
                
                childDescribe.textColor = allUnitColor
                //                (b as! UIButton).backgroundColor = UIColor.black
            }
        }
    }
}

//协议的实现
@objc protocol  ThickButtonDelagate : NSObjectProtocol{
    @objc func clickChangePage(_ thickButton:ThickButton, buttonIndex:NSInteger)
}
