//
//  HeaderViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/22.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SwiftyJSON
import Kingfisher

class HeaderViewController: AddNavViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let largeHeaderView = UIImageView.init()
    
    var headerImageData:NSMutableArray = []
    var fieldsStr:String!
    var fileUrl:String!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    
    override func viewDidLoad() {
        self.title = "头像"
        self.view.backgroundColor = UIColor.white
        
        let rightBtn = UIButton.init()
        rightBtn.sizeToFit()
        let rightImg = UIImage.init(named: "more")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let newImageNormal = rightImg?.imageWithTintColor(color: UIColor.white,blendMode: .overlay)
        rightBtn.setImage(newImageNormal, for: UIControlState.normal)
        rightBtn.addTarget(self, action: #selector(openSelector), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        super.viewDidLoad()
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        // Do any additional setup after loading the view.
        createContent()
    }
    
    func createContent(){
        
        largeHeaderView.frame.size = CGSize(width: kScreenWidth, height: 100)
        largeHeaderView.frame.origin.x = 0
        let imageUrlStr = self.userDefault.object(forKey: "UserHeaderImg") as! String
        largeHeaderView.kf.setImage(with: ImageResource(downloadURL:NSURL.init(string: imageUrlStr)! as URL), placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil, completionHandler: nil)
        largeHeaderView.contentMode = .scaleAspectFill
        largeHeaderView.center.y = (kScreenHeight - bottomSafeAreaHeight - largeHeaderView.frame.height)/2
        self.view.addSubview(largeHeaderView)
    }
    
    @objc func openSelector(){
        let actionSheet = UIAlertController.init(title: "请选择", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        // 命令（样式：退出Cancel，警告Destructive-按钮标题为红色，默认Default）
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler:{
            action in
            print("关闭")
        })
        let deleteAction = UIAlertAction(title: "拍摄照片", style: UIAlertActionStyle.default, handler: {
            action in
            print("拍摄照片")
            if self.cameraPermission() == true {
                self.cameraEvent()
            }else{
                self.gotoSetting()
            }
            
        })
        let archiveAction = UIAlertAction(title: "本地相册", style: UIAlertActionStyle.default, handler: {
            action in
            print("本地相册")
            if self.PhotoLibraryPermission() == true{
                self.photoEvent()
            }else{
                self.gotoSetting()
            }
        })
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(archiveAction)
        self.present(actionSheet, animated: false, completion: nil)
    }
   /*
     判断相机是否有权限
     return:有权限返回true，无权限返回false
     */
    func cameraPermission() -> Bool{
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted){
            return false
        }else{
            return true
        }
    }
    
    func cameraEvent(){
        let pickerCamera = UIImagePickerController()
        pickerCamera.sourceType = .camera
        pickerCamera.allowsEditing = true
        pickerCamera.delegate = self
        self.present(pickerCamera, animated: true, completion: nil)
    }
    
    /*
     判断相册是否有权限
     return:有权限返回true，无权限返回false
     */
    func PhotoLibraryPermission() -> Bool{
        let libraryStatus:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if (libraryStatus == PHAuthorizationStatus.denied || libraryStatus == PHAuthorizationStatus.restricted){
            return false
        }else{
            return true
        }
    }
    
    func photoEvent(){
        
        let pickerPhoto = UIImagePickerController()
        pickerPhoto.sourceType = .photoLibrary
        pickerPhoto.allowsEditing = true
        pickerPhoto.delegate = self
        self.present(pickerPhoto, animated: true, completion: nil)
        
    }
    
    //去设置权限
    
    func gotoSetting(){
        
        let alertController:UIAlertController=UIAlertController.init(title: "去设置", message: "设置-》通用-》", preferredStyle: UIAlertControllerStyle.alert)
        let sure:UIAlertAction=UIAlertAction.init(title: "去开启权限", style: UIAlertActionStyle.default) { (ac) in
            
            let url=URL.init(string: UIApplicationOpenSettingsURLString)

            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: { (ist) in
                    
                })
            }

        }

        alertController.addAction(sure)

        self.present(alertController, animated: true) {

        }

    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) {
            var img:UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
            if picker.allowsEditing {
                img = info[UIImagePickerControllerEditedImage] as? UIImage
            }
            
            self.headerImageData.add(img!)
            self.uploadHeaderImg()
            //将img转为data
//            let imageData = UIImagePNGRepresentation(img)
        }
        
    }
    
    //点击系统自定义取消按钮的回调
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    ///上传头像图片
    @objc func uploadHeaderImg() {
        MyProgressHUD.showStatusInfo("更换头像中...")
        NetworkTools.upload(urlString: "http", params: nil , images: headerImageData as! [UIImage], success: { (successBack) in
            print(successBack ?? "default value")
            if JSON(successBack!)["status"].stringValue == "success"{
                //关闭页面，通知列表刷新
                let successData = JSON(successBack!)["data"]
                self.fileUrl = successData[0]["filePath"].stringValue
                self.fieldsStr = successData[0]["fileId"].stringValue
                self.updateHeader()
            }else{
                MyProgressHUD.dismiss()
                if JSON(successBack!)["msg"].string == nil {
                    self.present(windowAlert(msges: "更换失败"), animated: true, completion: nil)
                }else{
                    self.present(windowAlert(msges: JSON(successBack!)["msg"].stringValue), animated: true, completion: nil)
                }
            }
        }) { (ErrorBack) in
            MyProgressHUD.dismiss()
            self.present(windowAlert(msges: "更换请求失败"), animated: true, completion: nil)
            print("error:\(ErrorBack)")
            return
        }
    }
    
    ///更换头像
    func updateHeader(){
        print("执行更换头像操作")
        let infoData = ["user_id":userId,"file_ids":fieldsStr,"photo_url":fileUrl] as [String : Any]
        let contentData : [String : Any] = ["method":"uploadHeadPortrait","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    MyProgressHUD.dismiss()
                    let overUrl = "http://" + self.userDefault.string(forKey: "AppUrlAndPort")! + self.fileUrl
                    self.largeHeaderView.dowloadFromServer(link: overUrl, contentMode: UIViewContentMode.scaleAspectFit)
                    MyProgressHUD.showSuccess("修改成功")
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "修改失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "修改请求失败"), animated: true, completion: nil)
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
