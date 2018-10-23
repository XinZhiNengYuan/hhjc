//
//  HeaderViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/22.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class HeaderViewController: AddNavViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let largeHeaderView = UIImageView.init()
    
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

        // Do any additional setup after loading the view.
        createContent()
    }
    
    func createContent(){
        
        largeHeaderView.frame.size = CGSize(width: kScreenWidth, height: 100)
        largeHeaderView.frame.origin.x = 0
        largeHeaderView.center.y = self.view.center.y
        largeHeaderView.image = UIImage(named: "Bitmap")
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
            self.cameraEvent()
        })
        let archiveAction = UIAlertAction(title: "本地相册", style: UIAlertActionStyle.default, handler: {
            action in
            print("本地相册")
            self.photoEvent()
        })
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(archiveAction)
        self.present(actionSheet, animated: false, completion: nil)
    }
    
    func cameraEvent(){
        let pickerCamera = UIImagePickerController()
        pickerCamera.sourceType = .camera
        pickerCamera.delegate = self
        self.present(pickerCamera, animated: true, completion: nil)
    }
    func photoEvent(){
        
        let pickerPhoto = UIImagePickerController()
        pickerPhoto.sourceType = .photoLibrary
        pickerPhoto.delegate = self
        self.present(pickerPhoto, animated: true, completion: nil)
        
    }
    
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imagePickerc = info[UIImagePickerControllerOriginalImage] as! UIImage
         self.largeHeaderView.contentMode = .scaleAspectFit
        largeHeaderView.image = imagePickerc
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //点击系统自定义取消按钮的回调
    
    @objc internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
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
