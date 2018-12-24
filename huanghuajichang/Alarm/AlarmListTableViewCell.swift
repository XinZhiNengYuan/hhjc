//
//  AlarmListTableViewCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/27.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class AlarmListTableViewCell: UITableViewCell {
    
    var itemIcon:UIView!
    var itemTitle:UILabel!
    var itemStatus:UILabel!
    var itemName:UILabel!
    var itemTime:UILabel!
    var itemId:String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    func setUI(){
        let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 85))
        contentView.backgroundColor = UIColor.white
        self.addSubview(contentView)
        self.backgroundColor = allListBackColor
        
        itemIcon = UIView.init(frame: CGRect(x: 15, y: 20, width: 8, height: 8))
        itemIcon.backgroundColor = UIColor.red
        itemIcon.layer.cornerRadius = 4
        contentView.addSubview(itemIcon)
        
        itemTitle = UILabel.init(frame: CGRect(x: 30, y: 15, width: 200, height: 20))
        itemTitle.textColor = allFontColor
        itemTitle.font = UIFont(name: "PingFangSC-Regular", size: 15)
        contentView.addSubview(itemTitle)
        
        itemStatus = UILabel.init(frame: CGRect(x: itemTitle.frame.width+itemTitle.frame.origin.x+5, y: 15, width: 60, height: 20))
        itemStatus.layer.borderWidth = 1
        itemStatus.layer.borderColor = topValueColor.cgColor
        itemStatus.textAlignment = .center
        itemStatus.textColor = topValueColor
        itemStatus.font = UIFont(name: "PingFangSC-Regular", size: 11)
        itemStatus.layer.masksToBounds = true
        contentView.addSubview(itemStatus)
        
        itemName = UILabel.init(frame: CGRect(x: 30, y: 40, width: kScreenWidth, height: 15))
        itemName.textColor = allUnitColor
        itemName.font = UIFont(name: "PingFangSC-Regular", size: 12)
        contentView.addSubview(itemName)
        
        itemTime = UILabel.init(frame: CGRect(x: 30, y: 60, width: kScreenWidth, height: 15))
        itemTime.textColor = allUnitColor
        itemTime.font = UIFont(name: "PingFangSC-Regular", size: 12)
        contentView.addSubview(itemTime)
    }
    func changUI(realTitle:String,realStatus:String) {
        itemTitle.frame.size.width = itemTitle.getLabelWidth(str: realTitle, font: UIFont(name: "PingFangSC-Regular", size: 15)!, height: 20)
        itemStatus.frame.size.width = itemTitle.getLabelWidth(str: realStatus, font: UIFont(name: "PingFangSC-Regular", size: 11)!, height: 20)
        itemStatus.frame = CGRect(x: itemTitle.frame.width+itemTitle.frame.origin.x+5, y: 15, width: itemStatus.frame.size.width+5, height: 20)
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UILabel{
    /// 动态计算Label宽度
    
    func getLabelWidth(str: String, font: UIFont, height: CGFloat)-> CGFloat {
        
        let statusLabelText:NSString = str as NSString
        
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
        
        return strSize.width
        
    }
    
    
    
    /// 动态计算Label高度
    
    func getLabelHegit(str: String, font: UIFont, width: CGFloat)-> CGFloat {
        
        let statusLabelText: NSString = str as NSString
        
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : AnyObject], context: nil).size
        
        return strSize.height
        
    }
}
