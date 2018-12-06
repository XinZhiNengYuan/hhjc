//
//  RecordListTableViewCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/19.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class RecordListTableViewCell: UITableViewCell {
    
    var itemId:String!
    var itemImage:UIImageView?
    var itemImageCount:UILabel?
    var itemTitle:UILabel?
    var itemStatus:UILabel?
    var itemCreator:UILabel?
    var itemHandler:UILabel?
    var itemDate:UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    func setupUI() {
        self.backgroundColor = allListBackColor
        let contentView:UIView = UIView.init(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 80))
        contentView.backgroundColor = UIColor.white
        self.addSubview(contentView)
        
        itemImage = UIImageView.init(frame: CGRect(x: 10, y: 10, width: 80, height: 60))
        // 圆角
//        itemImage?.layer.cornerRadius = (itemImage?.frame.width)! / 2
        // image还需要加上这一句, 不然无效
        itemImage?.layer.masksToBounds = true
        itemImage?.contentMode = UIViewContentMode.scaleToFill
        contentView.addSubview(itemImage!)
        
        itemTitle = UILabel.init(frame: CGRect(x: 100, y: 10, width: kScreenWidth-100-50, height: 20))
        itemTitle?.textColor = allFontColor
        itemTitle?.numberOfLines = 1
        itemTitle?.lineBreakMode = .byTruncatingTail
        itemTitle?.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(itemTitle!)
        
        itemCreator = UILabel.init(frame: CGRect(x: 100, y: 30, width: kScreenWidth-100-50, height: 20))
        itemCreator?.textColor = UIColor(red: 113/255, green: 112/255, blue: 112/255, alpha: 1)
        itemCreator?.numberOfLines = 1
        itemCreator?.lineBreakMode = .byTruncatingTail
        itemCreator?.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(itemCreator!)
        
        itemHandler = UILabel.init(frame: CGRect(x: 200, y: 30, width: kScreenWidth-100-50, height: 20))
        itemHandler?.textColor = UIColor(red: 113/255, green: 112/255, blue: 112/255, alpha: 1)
        itemHandler?.numberOfLines = 1
        itemHandler?.lineBreakMode = .byTruncatingTail
        itemHandler?.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(itemHandler!)
        
        itemStatus = UILabel.init(frame: CGRect(x: kScreenWidth-50, y: 15, width: 40, height: 20))
        itemStatus?.layer.masksToBounds = true
        itemStatus?.layer.borderWidth = 1
        itemStatus?.layer.borderColor = UIColor(red: 143/255, green: 144/255, blue: 145/255, alpha: 1).cgColor
        itemStatus?.textColor = UIColor(red: 158/255, green: 159/255, blue: 160/255, alpha: 1)
        itemStatus?.textAlignment = .center
        itemStatus?.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(itemStatus!)
        
        itemDate = UILabel.init(frame: CGRect(x: 100, y: 50, width: kScreenWidth-60, height: 20))
        itemDate?.font = UIFont.systemFont(ofSize: 12)
        itemDate?.textColor = UIColor(red: 113/255, green: 112/255, blue: 112/255, alpha: 1)
        contentView.addSubview(itemDate!)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
