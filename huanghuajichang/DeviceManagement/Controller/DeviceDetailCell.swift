//
//  DeviceDetailCell.swift
//  huanghuajichang
//
//  Created by zx on 2018/9/30.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DeviceDetailCell: UITableViewCell {

    let mView = UIView()
    let mLabelLeft = UILabel()
    let mLabelRight = UITextView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews(){
        mLabelLeft.frame = CGRect(x: 10, y: 0, width: 60, height: 40)
        mLabelLeft.textAlignment = .left
        mLabelLeft.font = UIFont.boldSystemFont(ofSize: 12)
        mView.addSubview(mLabelLeft)
        
        let mLabelCenter = UILabel(frame: CGRect(x: 70, y: 0, width: 5, height: 40))
        mLabelCenter.textAlignment = .left
        mLabelCenter.font = UIFont.boldSystemFont(ofSize: 12)
        mLabelCenter.text = ":"
        mView.addSubview(mLabelCenter)
        mLabelRight.font = UIFont.boldSystemFont(ofSize: 12)
        mLabelRight.isEditable = false
        mLabelRight.isSelectable = false
        mView.addSubview(mLabelRight)
        let bottomLine = UIView()
        bottomLine.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: 1)
        bottomLine.layer.backgroundColor = UIColor.gray.cgColor
        mView.addSubview(bottomLine)
        
        self.contentView.addSubview(mView)
        
    }

}
