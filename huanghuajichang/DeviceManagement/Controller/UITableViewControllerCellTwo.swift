//
//  UITableViewControllerCellTwo.swift
//  huanghuajichang
//  二级菜单
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 zx. All rights reserved.
//

import UIKit

class UITableViewControllerCellTwo: UITableViewCell {
    let mView : UIView = UIView()
    let mLabel : UILabel = UILabel()
    let rectButtonShapeLayer = CAShapeLayer()
    let rectTopShapeLayer = CAShapeLayer()
    let mainTopPath = UIBezierPath()
    let mainButtonPath = UIBezierPath()
    let mNum : UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupUI() {
        mView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        mView.backgroundColor = UIColor(red: 237/255, green: 242/255, blue: 247/255, alpha: 1)
        self.contentView.addSubview(mView)
        mLabel.frame = CGRect(x: (mView.frame.width*1/4-30), y: 5, width: mView.frame.width*1/4, height: 30)
        mLabel.font = UIFont.boldSystemFont(ofSize: 14)
        mLabel.textAlignment = .center
        mLabel.layer.borderWidth = 1
        mLabel.layer.borderColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1).cgColor
        mLabel.layer.cornerRadius = 10
        mLabel.textColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1)
        mLabel.highlightedTextColor = UIColor.white
        mNum.frame = CGRect(x: mView.frame.width/4*2, y: 0, width: 40, height: 40)
        mNum.textColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        mNum.font = UIFont.boldSystemFont(ofSize: 11)
        mView.addSubview(mNum)
        mView.addSubview(mLabel)
    }
    
    //绘制圆点下边的直线
    func setBottomLine(){
        
        mainButtonPath.move(to: CGPoint(x: 20, y: 15))//开始绘制，表示这个点是起点
        mainButtonPath.addLine(to: CGPoint(x: 20, y: 40))//设置终点
        rectButtonShapeLayer.path = mainButtonPath.cgPath
        rectButtonShapeLayer.lineWidth = 2
        rectButtonShapeLayer.strokeColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor//路径颜色
        mView.layer.addSublayer(rectButtonShapeLayer)
        //        mainPath.removeAllPoints() //删除所有点和线
        
    }
    
    func setTopLine(){
        
        mainTopPath.move(to: CGPoint(x: 20, y: 15))//开始绘制，表示这个点是起点
        mainTopPath.addLine(to: CGPoint(x: 20, y: 0))//设置终点
        rectTopShapeLayer.path = mainTopPath.cgPath
        rectTopShapeLayer.lineWidth = 2
        rectTopShapeLayer.strokeColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor//路径颜色
        mView.layer.addSublayer(rectTopShapeLayer)
        //        mainPath.removeAllPoints() //删除所有点和线
    }
    
    func removeAllLine(){
        mainTopPath.removeAllPoints()
        mainButtonPath.removeAllPoints()
    }
}
