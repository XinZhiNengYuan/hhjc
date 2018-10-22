//
//  PersonalDetailTableViewCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/22.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PersonalDetailTableViewCell: UITableViewCell {
    
    var itemTitle:UILabel!
    var itemRightIcon:UIImageView!
    var itemImage:UIImageView!
    var itemRealMsg:UILabel!
    var separatorLine:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.setUpUI()
    }
    
    func setUpUI(isHeaderView:Bool, hasRightIcon:Bool, cellSize:CGSize) {
        
        let rightImg = UIImage.init(named: "进入")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let newImageNormal = rightImg?.imageWithTintColor(color: UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1),blendMode: .overlay)
        
        if isHeaderView {//右侧是图片
            itemTitle = UILabel.init(frame: CGRect(x: 10, y: 20, width: 50, height: 30))
            itemTitle?.textColor = allUnitColor
            itemTitle?.font = UIFont.systemFont(ofSize: 15)
            self.addSubview(itemTitle!)
            
            itemImage = UIImageView.init(frame: CGRect(x: cellSize.width-80, y: 10, width: 50, height: 50))
            itemImage.layer.cornerRadius = 5
            self.addSubview(itemImage!)
            
            itemRightIcon = UIImageView.init(frame: CGRect(x: cellSize.width-20, y: 27.5, width: 10, height: 15))
            itemRightIcon.image = newImageNormal
            self.addSubview(itemRightIcon)
        }else {
            itemTitle = UILabel.init(frame: CGRect(x: 10, y: 10, width: 50, height: 30))
            itemTitle?.textColor = allUnitColor
            itemTitle?.font = UIFont.systemFont(ofSize: 15)
            self.addSubview(itemTitle!)
            
            if hasRightIcon {//有右侧箭头
                itemRealMsg = UILabel.init(frame: CGRect(x: 70, y: 10, width: cellSize.width-95, height: 30))
                itemRealMsg.textAlignment = .right
                itemRealMsg.textColor = UIColor.black
                itemRealMsg.font = UIFont.systemFont(ofSize: 15)
                self.addSubview(itemRealMsg)
                
                itemRightIcon = UIImageView.init(frame: CGRect(x: cellSize.width-20, y: 17.5, width: 10, height: 15))
                itemRightIcon.image = newImageNormal
                self.addSubview(itemRightIcon!)
            }else{//右侧只有文本
                itemRealMsg = UILabel.init(frame: CGRect(x: 70, y: 10, width: cellSize.width-80, height: 30))
                itemRealMsg.textAlignment = .right
                itemRealMsg.textColor = UIColor.black
                itemRealMsg.font = UIFont.systemFont(ofSize: 15)
                self.addSubview(itemRealMsg)
            }
        }
        separatorLine = UIView.init(frame: CGRect(x: 0, y: cellSize.height-1, width: cellSize.width, height: 1))
        separatorLine.backgroundColor = allListBackColor
        self.addSubview(separatorLine)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
