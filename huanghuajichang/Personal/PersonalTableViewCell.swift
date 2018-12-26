//
//  PersonalTableViewCell.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/6.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class PersonalTableViewCell: UITableViewCell {

    var itemImage:UIImageView?
    var itemTitle:UILabel?
    var itemRightIcon:UIImageView?
    var itemUrlId : String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    func setUpUI() {
        itemImage = UIImageView.init(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        // 圆角指定为长度一半
        itemImage?.layer.cornerRadius = (itemImage?.frame.width)! / 2
        // image还需要加上这一句, 不然无效
        itemImage?.layer.masksToBounds = true
        itemImage?.contentMode = UIViewContentMode.center
        self.addSubview(itemImage!)
        
        itemTitle = UILabel.init(frame: CGRect(x: 50, y: 10, width: 200, height: 30))
        itemTitle?.textColor = UIColor.black
        itemTitle?.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(itemTitle!)
        
        itemRightIcon = UIImageView.init(frame: CGRect(x: kScreenWidth-25, y: 17.5, width: 10, height: 15))
        self.addSubview(itemRightIcon!)
        
    }
    
    func setValueForCell(dic: NSDictionary) {
        itemImage?.image = UIImage.init(named: "Group 71")
        itemTitle?.text = "1"
        itemRightIcon?.image = UIImage.init(named: "Group 71")
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        //仿写cell点击效果，但是不会影响子view的颜色
        UIView.animate(withDuration: 0.3) {
            if selected {
                self.contentView.backgroundColor = UIColor.init(white: 0.85, alpha: 1)
            }else{
                self.contentView.backgroundColor = UIColor.white
            }
        }
        // Configure the view for the selected state
    }
    

}
