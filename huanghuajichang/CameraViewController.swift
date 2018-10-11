//
//  CameraViewController.swift
//  XinaoEnergy
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

import AVFoundation
import Photos


class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCapturePhotoCaptureDelegate {
    var cameraView = CameraView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        cameraView = CameraView(frame: UIScreen.main.bounds)
        self.view.addSubview(cameraView)
        cameraView.cameraButton.addTarget(self, action: #selector(CameraViewController.cameraEvent), for: .touchUpInside)
        cameraView.photoButton.addTarget(self, action: #selector(CameraViewController.photoEvent), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func cameraEvent(){
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
    @objc func photoEvent(){
        let pickerPhotos = UIImagePickerController()
        pickerPhotos.delegate = self
        self.present(pickerPhotos, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[String:Any]){
        let imagePickerc = info[UIImagePickerControllerOriginalImage] as!UIImage
        cameraView.image.image = imagePickerc
        self.dismiss(animated:true,completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
