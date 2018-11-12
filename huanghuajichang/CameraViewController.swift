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


class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCapturePhotoCaptureDelegate {
    var photoListr : [UIImage] = []
    var imageView = UIView()
    var addBut : UIButton!
    var  viewOption : UIView!
    override func viewWillAppear(_ animated: Bool){
        self.title = "图片编辑"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        imageView.frame = CGRect(x: 10, y: Int(UIApplication.shared.statusBarFrame.height+60), width: Int(KUIScreenWidth-20), height: 60)
        imageMethods()
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:设置设置添加按钮
    func setAddBut(){
        addBut = UIButton(frame: CGRect(x: 75*photoListr.count, y: 10, width: 40, height: 40))
        addBut.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addBut.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addBut.layer.borderWidth = 1
        addBut.tag = 3001
        addBut.setTitleColor(UIColor.white, for: UIControlState.normal)
        addBut.addTarget(self, action: #selector(actionSheet), for: .touchUpInside)
//        view.addSubview(addBut)
        imageView.addSubview(addBut)
    }
    
    func imageMethods(){
        for i in 0..<photoListr.count{
            let viewOption = UIView()
            viewOption.frame = CGRect(x: 75*i, y: 0, width: 60, height: Int(imageView.frame.height))
            let image = UIImageView()
            image.tag = i+1000
            image.frame = CGRect(x: 0, y: 0, width: 60, height: Int(imageView.frame.height))
            image.image = photoListr[i]
            viewOption.addSubview(image)
            let deleteBut = UIButton(frame: CGRect(x: 57, y: -7, width: 20, height: 20))
            deleteBut.setImage(UIImage(named: "删除"), for: UIControlState.normal)
//            deleteBut.layer.borderColor = UIColor.black.cgColor
//            deleteBut.layer.borderWidth = 2
            deleteBut.tag = i+2000
            deleteBut.addTarget(self, action: #selector(deleteImg), for: UIControlEvents.touchUpInside)
            viewOption.addSubview(deleteBut)
            imageView.addSubview(viewOption)
        }
        
        if photoListr.count >= 3{
            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
        view.addSubview(imageView)
        
    }
    
    func addPic(pic : UIImage){
        let addBtn = imageView.viewWithTag(3001) as! UIButton
        addBtn.removeTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        addBtn.removeFromSuperview()
        let viewOption = UIView()
        viewOption.tag = 4000+photoListr.count
        viewOption.frame = CGRect(x: 75*photoListr.count, y: 0, width: 60, height: Int(imageView.frame.height))
        let image = UIImageView()
        image.image = UIImage(named: "image")
        image.tag = photoListr.count + 1000
        image.frame = CGRect(x: 0, y: 0, width: 60, height: Int(imageView.frame.height))
        image.image = pic
        viewOption.addSubview(image)
        let deleteBut = UIButton(frame: CGRect(x: 57, y: -7, width: 20, height: 20))
        deleteBut.setImage(UIImage(named: "删除"), for: UIControlState.normal)
        deleteBut.tag = photoListr.count + 2000
//        deleteBut.layer.borderColor = UIColor.black.cgColor
//        deleteBut.layer.borderWidth = 2
        deleteBut.addTarget(self, action: #selector(deleteImg), for: UIControlEvents.touchUpInside)
        viewOption.addSubview(deleteBut)
        imageView.addSubview(viewOption)
        photoListr.append(pic)
        if photoListr.count >= 3{
            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
    }
    
    @objc func deleteImg(button:UIButton){
        print(button.tag)
        let index = button.tag - 2000
        button.superview?.superview?.removeFromSuperview()
        photoListr.remove(at: index)
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
        print(imagePickerc)
//        photoListr.append(imagePickerc)
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
