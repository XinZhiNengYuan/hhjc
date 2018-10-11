//
//  UITableViewControllerCellFore.swift
//  huanghuajichang
//列表
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class UITableViewControllerCellFore: UITableViewCell {

    let mView = UIView()
    let topLeft = UILabel()
    let topRight = UILabel()
    let midelLeft = UILabel()
    let midelCenter = UILabel()
    let midelRight = UIImageView()
    let bottomLeft = UIImageView()
    let bottomRight = UILabel()
//    var callback = {()->()in
//
//    }
    
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
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func layoutSubviews(){
        self.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        mView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90)
        mView.backgroundColor = UIColor.white
        topLeft.frame = CGRect(x: 20, y: 10, width: UIScreen.main.bounds.width*1/4, height: 25)
        topLeft.textColor = UIColor.black
        topLeft.font = UIFont.boldSystemFont(ofSize: 12)
        mView.addSubview(topLeft)
        
        topRight.frame = CGRect(x: UIScreen.main.bounds.width*1/4+20, y: 10, width: UIScreen.main.bounds.width*1/3, height: 20)
        topRight.textColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        topRight.layer.borderColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1).cgColor
        topRight.layer.borderWidth = 2
        topRight.textAlignment = .center
        topRight.font = UIFont.boldSystemFont(ofSize: 12)
        mView.addSubview(topRight)
        
        midelLeft.frame = CGRect(x: 20, y: 40, width: 70, height: 20)
        midelLeft.font = UIFont.boldSystemFont(ofSize: 12)
        mView.addSubview(midelLeft)
        
        midelCenter.frame = CGRect(x: 90, y: 40, width: 50, height: 20)
        midelCenter.backgroundColor = UIColor(red: 226/255, green: 242/255, blue: 255/255, alpha: 1)
        midelCenter.font = UIFont.boldSystemFont(ofSize: 12)
        mView.addSubview(midelCenter)
        
        midelRight.frame = CGRect(x: UIScreen.main.bounds.width-40, y: 40, width: 10, height: 10)
        midelRight.image = UIImage(named: "进入")
        mView.addSubview(midelRight)
        
        bottomLeft.frame = CGRect(x: 20, y: 70, width: 15, height: 20)
        bottomLeft.image = UIImage(named: "定位")
        mView.addSubview(bottomLeft)
        
        bottomRight.frame = CGRect(x: 40, y: 70, width: UIScreen.main.bounds.width-40, height: 20)
        bottomRight.textColor = UIColor(red: 121/255, green: 121/255, blue: 121/255, alpha: 1)
        bottomRight.font = UIFont.boldSystemFont(ofSize: 10)
        mView.addSubview(bottomRight)
        
//        let gesture = UITapGestureRecognizer()
//        gesture.delegate = self
//        gesture.addTarget(self, action: #selector(touchFirst))
//        mView.addGestureRecognizer(gesture)
        self.contentView.addSubview(mView)
    }
//    @objc func touchFirst(){
//        callback()
//    }

}
