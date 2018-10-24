//
//  ScanAndEditViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class ScanAndEditViewController: AddNavViewController {

    var rightEditBtn:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "记录详情"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:(UIFont(name: "PingFangSC-Regular", size: 18))!]
        self.view.backgroundColor = UIColor.white
        rightEditBtn = UIBarButtonItem.init(title: "编辑", style: UIBarButtonItemStyle.done, target: self, action: #selector(changeToEdit))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: "PingFangSC-Regular", size: 6)!], for: UIControlState.normal)//未生效
        rightEditBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightEditBtn
        // Do any additional setup after loading the view.
        createDetailContent()
    }
    
    @objc func changeToEdit(){
        let editVc = AddDailyRecordViewController()
        editVc.pageType = "edit"
        self.navigationController?.pushViewController(editVc, animated: false)
    }
    
    func createDetailContent(){
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        let titleLabel = UILabel.init(frame:CGRect(x: 50, y: 20, width: kScreenWidth-100, height: 20))
        titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        titleLabel.numberOfLines = 1
        titleLabel.text = "能源管配电站航空港110KV变电变站…"
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        scrollView.addSubview(titleLabel)
        
        let timeLabel = UILabel.init(frame:CGRect(x: 131, y: 50, width: kScreenWidth-262, height: 14))
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size:10)
        timeLabel.text = "2018-09-20 18:30:20"
        timeLabel.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        scrollView.addSubview(timeLabel)
        
        let sperLine = UIView.init(frame: CGRect(x: 0, y: 74, width: kScreenWidth, height: 1))
        sperLine.backgroundColor = allListBackColor
        scrollView.addSubview(sperLine)
        
        let describeTextView = UITextView.init(frame: CGRect(x: 20, y: 85, width: kScreenWidth-40, height: 150))
        describeTextView.font = UIFont(name:"PingFangSC-Regular", size:13)
        describeTextView.text = "记录详细描述信息记录详细描述信息记录，详细描述信息记录详细描述信息记录详细描述，信息记录详细描述信息记录详细描述信息记录详细，描述信息记录详细描述信息记录详细描述信息记录详细描述信息记录详细描述，信息记录详细描述信息记录详，细描述信息，记录详细描述信息记录，详细描述信息记录详细描述信，息记录详细描述信息，记录详细描述信息记录详细描述信息记录，详细描述信息记录详，细描述信息记录详细描述信息.1024。"
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 5   //行间距
        paragraphStyle.firstLineHeadIndent = 20    /**首行缩进宽度*/
        paragraphStyle.alignment = .left
        
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 13),
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        describeTextView.attributedText = NSAttributedString(string: describeTextView.text, attributes: attributes)
        describeTextView.textColor = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)//在上面设置之前使用不起效果
        describeTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //重置textView的高度
        describeTextView.frame.size.height = describeTextView.heightForTextView(textView: describeTextView, fixedWidth: kScreenWidth-40)
        scrollView.addSubview(describeTextView)
        
        let imageData = [1,2,3]
        for detailImage in imageData.enumerated(){
            let topHeight = describeTextView.frame.size.height+describeTextView.frame.origin.y
            let imageView = UIImageView.init(frame: CGRect(x: 20, y: CGFloat(detailImage.offset * 160) + CGFloat(10) + topHeight, width: kScreenWidth-40, height: 150))
            imageView.backgroundColor = UIColor.white
            imageView.image = UIImage(named:"update_huojian")
            imageView.layer.borderColor = UIColor.red.cgColor
            imageView.layer.borderWidth = 1
            scrollView.addSubview(imageView)
        }
        //重置scrollView的高度
        scrollView.contentSize = CGSize(width: kScreenWidth, height: describeTextView.frame.size.height+describeTextView.frame.origin.y+CGFloat(imageData.count*(160))+20)
        
        let dealView = UIView.init(frame: CGRect(x: 0, y: kScreenHeight-64-44, width: kScreenWidth, height: 44))
        dealView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.28)
        self.view.addSubview(dealView)
        
        let dealbtn = UIButton.init(frame: CGRect(x: (kScreenWidth-150)/2, y: 7, width: 150, height: 30))
        dealbtn.setTitle("确认处理", for: UIControlState.normal)
        dealbtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        dealbtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        dealbtn.backgroundColor = UIColor(red: 254/255, green: 160/255, blue: 33/255, alpha: 1)
        dealbtn.layer.cornerRadius = 8
        dealbtn.addTarget(self, action: #selector(dealPost), for: UIControlEvents.touchUpInside)
        dealView.addSubview(dealbtn)
    }
    
    @objc func dealPost(){
        print("执行处理操作")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UITextView{
    /**
     根据字符串的的长度来计算UITextView的高度
     
     - parameter textView:   UITextView
     - parameter fixedWidth:      UITextView宽度
     - returns:              返回UITextView的高度
     */
    func heightForTextView(textView: UITextView, fixedWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: fixedWidth, height: 999)
        let constraint = textView.sizeThatFits(size)
        return constraint.height
    }
}
