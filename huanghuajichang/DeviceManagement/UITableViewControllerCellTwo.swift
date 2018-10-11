//
//  UITableViewControllerCellTwo.swift
//  buttonDemo
//  二级菜单
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 zx. All rights reserved.
//

import UIKit

class UITableViewControllerCellTwo: UITableViewCell {
    let mView : UIView = UIView()
    let mLabel : UILabel = UILabel()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        mView.backgroundColor = UIColor(red: 237/255, green: 242/255, blue: 247/255, alpha: 1)
        self.contentView.addSubview(mView)
        mLabel.frame = CGRect(x: (mView.frame.width*1/3-30), y: 5, width: mView.frame.width*1/4, height: 30)
        mLabel.font = UIFont.boldSystemFont(ofSize: 14)
        mLabel.textAlignment = .center
        mLabel.layer.borderWidth = 1
        mLabel.layer.borderColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1).cgColor
        mLabel.layer.cornerRadius = 10
        mLabel.textColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1)
        mView.addSubview(mLabel)
    }
}
