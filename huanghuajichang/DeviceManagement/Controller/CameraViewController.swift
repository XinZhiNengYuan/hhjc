//
//  CameraViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 zx. All rights reserved.
//

import UIKit

import AVFoundation
import Photos
import Kingfisher

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCapturePhotoCaptureDelegate {
    var photoListr : [UIImage] = []
    var imageView = UIView()
    var addBut : UIButton!
    var equNo : String = ""
    var flagePageFrom : Int = 1 //1:默认表示从列表页面跳转过来，2:表示从搜索页跳转过来
    var  viewOption : UIView!
    var mView = UIView()
    var deviceDetailPageImageList : [String] = []
    var imgIdListStr : String = ""
    let cameraViewService = CameraViewService()
    let imageScrollViewWidth = Int(KUIScreenWidth-20)//图片区域的宽度
    var imageIndex = 0 //已经添加了的图片的数量
    var imageNumMax = 10//图片区域最多可放置的图片的数量
    override func viewWillAppear(_ animated: Bool){
        self.title = "图片编辑"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromCameraViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadImgs))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mView.frame = CGRect(x: 0, y: 0, width: KUIScreenWidth, height: KUIScreenHeight)
        mView.backgroundColor = UIColor.white
        if flagePageFrom == 1{
            imageView.frame = CGRect(x: 10, y: 20, width: Int(KUIScreenWidth-20), height: 160)
        }else{
            imageView.frame = CGRect(x: 10, y: Int(UIApplication.shared.statusBarFrame.height+(navigationController?.navigationBar.frame.height)!)+20, width: Int(KUIScreenWidth-20), height: 160)
        }
        
        imageMethods()
        NotificationCenter.default.addObserver(self, selector: #selector(goBackFromCameraViewController), name: NSNotification.Name(rawValue: "closeCameraViewController"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "closeCameraViewController"), object: nil)
    }
    
    @objc func goBackFromCameraViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func uploadImgs(){
        if photoListr.count > 0{
            cameraViewService.upLoadPic(images: photoListr, finished: { (fileId,status) in
                if status == "success"{
                    if fileId.count > 0{
                        self.imgIdListStr = self.imgIdListStr + "," + fileId
                    }
                    let userId = userDefault.string(forKey: "userId")
                    let token = userDefault.string(forKey: "userToken")
                    let contentData : [String:Any] = ["method":"equipmentedit","user_id": userId as Any,"token": token as Any,"info":["equNo":self.equNo,"files_id":self.imgIdListStr]]
                    self.cameraViewService.picIdAndEquId(contentData: contentData, successCall: {
                        self.present(windowAlert(msges: "上传成功"), animated: true, completion: nil)
                    }, errorCall: {
                        self.present(windowAlert(msges: "上传失败，请重新上传"), animated: true, completion: nil)
                    })
                }else if status == "sign_app_err"{
                    self.present(windowAlert(msges: "token失效"), animated: true, completion: nil)
                }else{
                    
                }
            }) {
                print("错误")
            }
        }
        if deviceDetailPageImageList.count > 0{
            print(deviceDetailPageImageList)
        }
        
    }
    
    //MARK:设置设置添加按钮
    func setAddBut(){
        if(imageIndex >= imageNumMax){
            addBut = UIButton(frame: CGRect(x: 75*(photoListr.count+deviceDetailPageImageList.count-imageNumMax)+10, y: 100, width: 40, height: 40))
        }else{
            addBut = UIButton(frame: CGRect(x: 75*(photoListr.count+deviceDetailPageImageList.count)+10, y: 20, width: 40, height: 40))
        }
        addBut.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addBut.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addBut.layer.borderWidth = 1
        addBut.tag = 3001 // 添加按钮
        addBut.setTitleColor(UIColor.white, for: UIControlState.normal)
        addBut.addTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        imageView.addSubview(addBut)
    }
    
    func imageMethods(){
        imageNumMax = imageScrollViewWidth/75
        self.imageIndex = 0
        print(deviceDetailPageImageList)
        if deviceDetailPageImageList.count > 0{
            for j in 0..<deviceDetailPageImageList.count{
                let viewOption = UIButton()
                viewOption.tag = 4100+j
                if(self.imageIndex >= imageNumMax){
                    viewOption.frame = CGRect(x: 75*(j-imageNumMax), y: 80, width: 70, height: 70)
                }else{
                    viewOption.frame = CGRect(x: 75*j, y: 0, width: 70, height: 70)
                }
                viewOption.addTarget(self, action: #selector(toSeePic(sender:)), for: UIControlEvents.touchUpInside)
                let image = UIImageView()
                image.tag = j+1000 // 图片
                image.frame = CGRect(x: 0, y: 10, width: 60, height: 60)
                image.kf.setImage(with: ImageResource(downloadURL:
                    URL.init(string:deviceDetailPageImageList[j])!), placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil, completionHandler: nil)
                viewOption.addSubview(image)
                let deleteBut = deleteBtn(tag: j + 5000)
                viewOption.addSubview(deleteBut)
                imageView.addSubview(viewOption)
                self.imageIndex += 1
            }
        }
        for i in 0..<photoListr.count{
            let viewOption = UIButton()
            viewOption.tag = 4000+i
            if(self.imageIndex >= imageNumMax){
                viewOption.frame = CGRect(x: 75*i+(deviceDetailPageImageList.count-imageNumMax)*75, y: 80, width: 70, height: 70)
            }else{
                viewOption.frame = CGRect(x: 75*i+deviceDetailPageImageList.count*75, y: 0, width: 70, height: 70)
            }
            viewOption.addTarget(self, action: #selector(toSeePic(sender:)), for: UIControlEvents.touchUpInside)
            let image = UIImageView()
            image.tag = i+1000+deviceDetailPageImageList.count // 图片
            image.frame = CGRect(x: 0, y: 10, width: 60, height: 60)
            image.image = photoListr[i]
            viewOption.addSubview(image)
            let deleteBut = deleteBtn(tag: i + 6000)
            viewOption.addSubview(deleteBut)
            imageView.addSubview(viewOption)
            self.imageIndex += 1
        }
        if deviceDetailPageImageList.count + photoListr.count >= 6{
//            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
        mView.addSubview(imageView)
        view.addSubview(mView)
    }
    
    func addPic(pic : UIImage){
        let addBtn = imageView.viewWithTag(3001) as! UIButton
        addBtn.removeTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        addBtn.removeFromSuperview()
        let viewOption = UIButton()
        viewOption.tag = 4000+photoListr.count // 图片所在图层
        
        if(self.imageIndex >= imageNumMax){
            viewOption.frame = CGRect(x: 75*(photoListr.count+deviceDetailPageImageList.count-imageNumMax), y: 80, width: 70, height: 70)
        }else{
            viewOption.frame = CGRect(x: 75*(photoListr.count+deviceDetailPageImageList.count), y: 0, width: 70, height: 70)
        }
        viewOption.addTarget(self, action: #selector(toSeePic(sender:)), for: UIControlEvents.touchUpInside)
        let image = UIImageView()
        image.image = UIImage(named: "image")
        image.tag = photoListr.count + 1000+deviceDetailPageImageList.count //图片
        image.frame = CGRect(x: 0, y: 10, width: 60, height: 60)
        image.image = pic
        viewOption.addSubview(image)
        let deleteBut = deleteBtn(tag: imageIndex + 6000)
        viewOption.addSubview(deleteBut)
        imageView.addSubview(viewOption)
        photoListr.append(pic)
        self.imageIndex += 1
        if deviceDetailPageImageList.count + photoListr.count >= 6{
            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
    }
    
    @objc func toSeePic(sender:UIButton){
        var indexForPic = sender.tag - 4000

        if indexForPic >= 100{//大于100是从详情页面带过来的图片
            indexForPic = indexForPic - 100
            
            let vc = PictureVisitControl(index: indexForPic, images: deviceDetailPageImageList)
            present(vc, animated: true, completion:  nil)
        }else{//小于100是当前自己添加的
            let vc = PictureVisitControl(index: indexForPic, images: photoListr)
            present(vc, animated: true, completion:  nil)
        }
        
        
    }
    
    func deleteBtn(tag : Int)->UIButton{
        let deleteBut = UIButton(frame: CGRect(x: 50, y: 0, width: 20, height: 20))
        deleteBut.setImage(UIImage(named: "删除"), for: UIControlState.normal)
        deleteBut.tag = tag // 删除按钮
        deleteBut.addTarget(self, action: #selector(deleteImg), for: UIControlEvents.touchUpInside)
        return deleteBut
    }
    @objc func deleteImg(button:UIButton){
        var index = button.tag - 5000 //根据下标的大小判断这个要删除的图片在那个数组里面 5000是deviceDetailPageImageList数组，6000是photoListr
        button.superview?.superview?.removeFromSuperview()
        if index >= 1000{
            index = index - 1000
            photoListr.remove(at: index)
        }else{
            deviceDetailPageImageList.remove(at: index)
        }
        self.imageIndex = self.imageIndex - 1
        clearImages(btn: button)
        //重新加载图片图层
        imageMethods()
    }
    
    func clearImages(btn button:UIButton){
        let imgs = button.superview?.superview?.subviews
        for children in imgs!{
            children.removeFromSuperview()
        }
    }
    func cameraEvent(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
        //创建图片控制器
        let picker = UIImagePickerController()
        //设置代理
        picker.delegate = self
        //设置来源
        picker.sourceType = UIImagePickerControllerSourceType.camera
        //允许编辑
        picker.allowsEditing = true
        self.present(picker,animated:true,completion: nil)
        }else{
            print("找不到相机")
        }
        
    }
    func photoEvent(){
        let pickerPhotos = UIImagePickerController()
        pickerPhotos.delegate = self
        self.present(pickerPhotos, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[String:Any]){
        let imagePickerc = info[UIImagePickerControllerOriginalImage] as!UIImage
        //添加图片
        addPic(pic : imagePickerc)
        self.dismiss(animated:true,completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:设置actionSheet
    @objc func actionSheet(){
        let alertSheet = UIAlertController(title: "提示", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let camera = UIAlertAction(title: "照相机", style: UIAlertActionStyle.default) { (action) in
            self.cameraEvent()
        }
        let photo = UIAlertAction(title: "相册", style: UIAlertActionStyle.destructive) { (action) in
            self.photoEvent()
        }
        alertSheet.addAction(camera)
        alertSheet.addAction(photo)
        alertSheet.addAction(cancel)
        self.present(alertSheet,animated: true,completion: nil)
    }
    
}
