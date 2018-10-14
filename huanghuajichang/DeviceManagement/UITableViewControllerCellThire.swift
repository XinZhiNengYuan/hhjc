//
//  UITableViewControllerCellThireTableViewCell.swift
//  huanghuajichang
//列表头
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class UITableViewControllerCellThire: UIView,UIGestureRecognizerDelegate {

    let mLabel : UILabel = UILabel()
    let mBorderLeft = UILabel()
    let mView : UIView = UIView()
    let mNum = UILabel()
    let rightPic = UIImageView()
    var isSelected : Bool = false
    
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
        mView.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width, height: 40)
        self.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        mBorderLeft.text = ""
        mBorderLeft.layer.borderWidth = 2
        mBorderLeft.frame = CGRect(x: 5, y: 5, width: 4, height: 30)
        mBorderLeft.layer.borderColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1).cgColor
        mLabel.frame = CGRect(x: 15, y: 0, width: mView.frame.width*1/3, height: mView.frame.height)
        mLabel.font = UIFont.boldSystemFont(ofSize: 14)
        mLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        mLabel.textAlignment = .left
        mNum.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 0, width: 40, height: 40)
        mNum.textColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        mNum.font = UIFont.boldSystemFont(ofSize: 11)
        if isSelected {
            rightPic.image = UIImage(named: "收起")
        }else{
            rightPic.image = UIImage(named: "展开")
        }
        
        rightPic.frame = CGRect(x: UIScreen.main.bounds.width-45, y: 15, width: 15, height: 10)
        mView.addSubview(mLabel)
        mView.addSubview(mBorderLeft)
        mView.addSubview(mNum)
        mView.addSubview(rightPic)
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
