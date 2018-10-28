//
//  HistorySearchListView.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/16.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class HistorySearchListView: UITableViewCell {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    let mView = UIView()
    var mHistoryList : [String]!
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height

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
        mView.frame = CGRect(x: 0, y: 100, width: screenWidth, height: 400)
        mView.backgroundColor = UIColor.white
        let mLabelTitle = UILabel(frame: CGRect(x: 40, y: 20, width: screenWidth, height: 40))
        mLabelTitle.font = UIFont.boldSystemFont(ofSize: 12)
        mLabelTitle.textColor = UIColor.black
        mLabelTitle.text = "历史搜索记录"
        
        let mLabel = UILabel(frame: CGRect(x: 40+mView.tag*60, y: 60, width: 50, height: 20))
        mLabel.font = UIFont.boldSystemFont(ofSize: 10)
        mLabel.textColor = UIColor.gray
        mLabel.textAlignment = .center
        mLabel.layer.borderColor = UIColor.gray.cgColor
        mLabel.layer.borderWidth = 1
        mLabel.layer.cornerRadius = 5
        mLabel.layer.backgroundColor = UIColor.white.cgColor
        mView.addSubview(mLabel)
        
        mView.addSubview(mLabelTitle)
        self.addSubview(mView)
    }
    
//    func setHistory (historyList:Array<String>)->Void{
//        for i:Int in 0..<historyList.count{
//            let mLabel = UILabel(frame: CGRect(x: 40+i*60, y: 60, width: 50, height: 20))
//            mLabel.text = historyList[i]
//            mLabel.font = UIFont.boldSystemFont(ofSize: 10)
//            mLabel.textColor = UIColor.gray
//            mLabel.textAlignment = .center
//            mLabel.layer.borderColor = UIColor.gray.cgColor
//            mLabel.layer.borderWidth = 1
//            mLabel.layer.cornerRadius = 5
//            mLabel.layer.backgroundColor = UIColor.white.cgColor
//            mView.addSubview(mLabel)
//        }
//    }
}
