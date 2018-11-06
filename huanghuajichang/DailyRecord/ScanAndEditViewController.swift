//
//  ScanAndEditViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScanAndEditViewController: AddNavViewController {

    var rightEditBtn:UIBarButtonItem!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var itemId:String!
    var detailJson:JSON!
    
    var titleLabel:UILabel!
    var timeLabel:UILabel!
    var describeTextView:UITextView!
    var imageData:NSArray = []
    var dealView:UIView!
    
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
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        itemId = userDefault.object(forKey: "recordId") as? String
        getDetailData()
        
    }
    
    @objc func changeToEdit(){
        let editVc = AddDailyRecordViewController()
        editVc.pageType = "edit"
        self.navigationController?.pushViewController(editVc, animated: false)
    }
    
    func getDetailData(){
        MyProgressHUD.showStatusInfo("加载中...")
        let infoData = ["id":itemId]
        let contentData : [String : Any] = ["method":"getOptionById","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.detailJson = JSON(value)["data"]
                    self.createDetailContent()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    print(type(of: JSON(value)["msg"]))
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    func createDetailContent(){
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        titleLabel = UILabel.init(frame:CGRect(x: 50, y: 20, width: kScreenWidth-100, height: 20))
        titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.text = self.detailJson["title"].stringValue
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        scrollView.addSubview(titleLabel)
        
        timeLabel = UILabel.init(frame:CGRect(x: 131, y: 50, width: kScreenWidth-262, height: 14))
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size:10)
        timeLabel.text = self.detailJson["staTime"].stringValue
        timeLabel.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        scrollView.addSubview(timeLabel)
        
        let sperLine = UIView.init(frame: CGRect(x: 0, y: 74, width: kScreenWidth, height: 1))
        sperLine.backgroundColor = allListBackColor
        scrollView.addSubview(sperLine)
        
        describeTextView = UITextView.init(frame: CGRect(x: 20, y: 85, width: kScreenWidth-40, height: 150))
        describeTextView.font = UIFont(name:"PingFangSC-Regular", size:13)
        describeTextView.text = self.detailJson["describe"].stringValue
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
        
        imageData = self.detailJson["filesId"].stringValue.components(separatedBy: ",") as NSArray
        
        for detailImage in imageData.enumerated(){
            let topHeight = describeTextView.frame.size.height+describeTextView.frame.origin.y
            let imageView = UIImageView.init(frame: CGRect(x: 20, y: CGFloat(detailImage.offset * 160) + CGFloat(10) + topHeight, width: kScreenWidth-40, height: 150))
            imageView.backgroundColor = UIColor.white
            let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (detailImage.element as! String)
            imageView.dowloadFromServer(link:imgurl as String, contentMode: .scaleAspectFit)
            imageView.layer.borderColor = UIColor.red.cgColor
            imageView.layer.borderWidth = 1
            scrollView.addSubview(imageView)
        }
        
        //重置scrollView的高度
        scrollView.contentSize = CGSize(width: kScreenWidth, height: describeTextView.frame.size.height+describeTextView.frame.origin.y+CGFloat(imageData.count*(160))+20)
        
        if self.detailJson["state"].intValue == 0 {
            dealView = UIView.init(frame: CGRect(x: 0, y: kScreenHeight-64-44, width: kScreenWidth, height: 44))
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
        
    }
    
    @objc func dealPost(){
        print("执行处理操作")
        MyProgressHUD.showStatusInfo("处理中...")
        let infoData = ["id":itemId]
        let contentData : [String : Any] = ["method":"updateOptionState","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.dealView.removeFromSuperview()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    print(type(of: JSON(value)["msg"]))
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "处理失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                self.present(windowAlert(msges: "处理请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
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
