//
//  ScanAndEditViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ScanAndEditViewController: AddNavViewController {
    
    var rightEditBtn:UIBarButtonItem!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var itemId:String!
    var detailJson:JSON!
    
    var titleLabel:UILabel!
    var peronsLabel:UILabel!
    var timeLabel:UILabel!
    var describeTextView:UITextView!
    var dealView:UIView!
    var scanImgData:[Any] = []
    var scanImgBtnData:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "记录详情"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:(UIFont(name: "PingFangSC-Regular", size: 18))!]
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(getDetailData), name: NSNotification.Name(rawValue: "updateDetail"), object: nil)
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
    
    ///获取详细信息
    @objc func getDetailData(){
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
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    func createDetailContent(){
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-navigationHeight))
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
        
        peronsLabel = UILabel.init(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 20))
        peronsLabel.font = UIFont(name: "PingFangSC-Regular", size:12)
        peronsLabel.text = "发布人:\(self.detailJson["userName"].stringValue)"
        peronsLabel.textAlignment = .center
        peronsLabel.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        scrollView.addSubview(peronsLabel)
        
        timeLabel = UILabel.init(frame:CGRect(x: 131, y: 80, width: kScreenWidth-262, height: 14))
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size:10)
        timeLabel.text = AddDailyRecordViewController.timeStampToString(timeStamp: self.detailJson["opeTime"].stringValue,timeAccurate: "minute")
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        scrollView.addSubview(timeLabel)
        
        let sperLine = UIView.init(frame: CGRect(x: 0, y: 104, width: kScreenWidth, height: 1))
        sperLine.backgroundColor = allListBackColor
        scrollView.addSubview(sperLine)
        
        describeTextView = UITextView.init(frame: CGRect(x: 20, y: 115, width: kScreenWidth-40, height: 150))
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
        describeTextView.isEditable = false
        describeTextView.isScrollEnabled = false
        //重置textView的高度
        describeTextView.frame.size.height = describeTextView.heightForTextView(textView: describeTextView, fixedWidth: kScreenWidth-40)
        scrollView.addSubview(describeTextView)
        scanImgData = []
        var imagesHeight:CGFloat = 0
        //获取系统存在的全局队列
        let queue = DispatchQueue.global(qos: .default)
        //使用信号量保证正确性
        //创建一个初始计数值为1的信号
        let semaphore = DispatchSemaphore(value: 1)
        
        for detailImage in self.detailJson["filePhotos"].enumerated(){
            let topHeight = describeTextView.frame.size.height+describeTextView.frame.origin.y
            let imageBtn = UIButton.init(frame: CGRect(x: 20, y: CGFloat(detailImage.offset * 210) + CGFloat(10) + topHeight, width: kScreenWidth-40, height: 200))
            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth-40, height: 200))
            imageView.backgroundColor = UIColor.white
            let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (self.detailJson["filePhotos"][detailImage.offset]["filePath"].stringValue)
            queue.async {
                //永久等待，直到Dispatch Semaphore的计数值 >= 1
                semaphore.wait()
                DispatchQueue.main.async {
                    imageView.kf.setImage(with: ImageResource(downloadURL:(NSURL.init(string: imgurl))! as URL), placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil) { (kfImage, kfError, kfcacheType, kfUrl) in
                        let size = self.disPlaySize(image: imageView.image!)
                        imageBtn.frame = CGRect(x: 20, y: imagesHeight + CGFloat(10*(detailImage.offset+1)) + topHeight, width: kScreenWidth-40, height: size.height)
                        imagesHeight += size.height
                        imageView.frame = CGRect(x:(kScreenWidth-40)/2 - (size.width)/2,y:0, width: size.width, height: size.height)
                        imageBtn.addSubview(imageView)
                        //重置scrollView的高度
                        scrollView.contentSize = CGSize(width: kScreenWidth, height: self.describeTextView.frame.size.height+self.describeTextView.frame.origin.y+imagesHeight+CGFloat(10*(detailImage.offset+1))+20)
//                        print("\(detailImage.offset)\(imageBtn.frame.origin.y)\(NSDate())")
                        scrollView.addSubview(imageBtn)
                        //发信号，使原来的信号计数值+1
                        semaphore.signal()
                    }
                }
            }
            
            imageBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
            imageBtn.layer.borderWidth = 1
            
            imageBtn.tag = 5000 + detailImage.offset
            imageBtn.addTarget(self, action: #selector(openScanImgPicker(sender:)), for: UIControlEvents.touchUpInside)
            
            scanImgData.append(imgurl)
            scanImgBtnData.append(imageBtn)
        }
        
        if self.detailJson["state"].intValue == 0 {
            ///编辑按钮
            rightEditBtn = UIBarButtonItem.init(title: "编辑", style: UIBarButtonItemStyle.done, target: self, action: #selector(changeToEdit))
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: "PingFangSC-Regular", size: 6)!], for: UIControlState.normal)//未生效
            rightEditBtn.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = rightEditBtn
            
            ///处理按钮视图
            dealView = UIView.init(frame: CGRect(x: 0, y: kScreenHeight-navigationHeight-tabBarHeight, width: kScreenWidth, height: tabBarHeight-bottomSafeAreaHeight))
            dealView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.28)
            self.view.addSubview(dealView)
            
            let dealbtn = UIButton.init(frame: CGRect(x: (kScreenWidth-150)/2, y: (tabBarHeight-bottomSafeAreaHeight-30)/2, width: 150, height: 30))
            dealbtn.setTitle("确认处理", for: UIControlState.normal)
            dealbtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            dealbtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            dealbtn.backgroundColor = UIColor.pg_color(withHexString: "#FF017FD1")
            dealbtn.layer.cornerRadius = 15
            dealbtn.addTarget(self, action: #selector(showConfirm), for: UIControlEvents.touchUpInside)
            dealView.addSubview(dealbtn)
        }else{
            peronsLabel.text = "发布人:\(self.detailJson["userName"].stringValue)" + "  " + "处理人:\(self.detailJson["staName"].stringValue)"
        }
        
    }
    ///处理日常记录操作
    @objc func dealPost(){
//        print("执行处理操作")
        MyProgressHUD.showStatusInfo("处理中...")
        let infoData = ["id":itemId,"user_id":userId]
        let contentData : [String : Any] = ["method":"updateOptionState","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.dealView.removeFromSuperview()
                    self.navigationItem.rightBarButtonItem = nil
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateList"), object: nil)
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
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "处理请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    //显示确认框
    @objc func showConfirm() {
        let alertController = UIAlertController(title:"提示",message:"您确定要处理吗？",preferredStyle: .alert)
        let canceAction = UIAlertAction(title:"取消",style:.cancel,handler:nil)
        let okAciton = UIAlertAction(title:"确定",style:.default,handler: {action in
            self.dealPost()
        })
        alertController.addAction(canceAction);
        alertController.addAction(okAciton);
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///打开详情界面的浏览图片器
    @objc func openScanImgPicker(sender:UIButton){
        ///index为当前点击了图片数组中的第几张图片,Urls为图片Url地址数组
        //**Urls必须传入为https或者http的图片地址数组,**
        var index = 0
        for img in scanImgBtnData.enumerated(){
            if (scanImgBtnData[img.offset] as! UIButton).tag == sender.tag{
                index = img.offset
            }
        }
        let vc = PictureVisitControl(index: index, images: scanImgData)
        present(vc, animated: true, completion:  nil)
    }
    
    func disPlaySize(image:UIImage)->CGSize{
        
        let scale = image.size.height / image.size.width
        var width = UIScreen.main.bounds.width - 40
        var height = width * scale
        if height > 300 {
            width = 300 / scale
            height = 300
        }
        return CGSize(width: width, height: height)
    }
    
    //最后要记得移除通知
    /// 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
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
