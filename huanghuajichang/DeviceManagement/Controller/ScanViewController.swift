//
//  ScanViewController.swift
//  ZZYQRCodeSwift
//
//  Created by 张泽宇 on 2017/5/24.
//  Copyright © 2017年 zzy. All rights reserved.
//

import UIKit

// 1.定义一个闭包类型
//格式: typealias 闭包名称 = (参数名称: 参数类型) -> 返回值类型
typealias QrCodeResult = (_ str: String) -> Void

class ScanViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var sessionManager:AVCaptureSessionManager?
    var link: CADisplayLink?
    var torchState = false
    //2. 声明一个变量
    var callBackClosure: QrCodeResult?
    
    @IBOutlet weak var scanTop: NSLayoutConstraint!
    @IBOutlet weak var scanView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        link = CADisplayLink(target: self, selector: #selector(scan))
        // 通过对这个值的观察, 我们发现传入的是比例
        // 注意: 参照是以横屏的左上角作为, 而不是以竖屏
        // 1.获取屏幕的frame
//        let viewRect = self.view.frame
//        // 2.获取扫描容器的frame
//        let containerRect = self.scanView.frame
//        let x = containerRect.origin.y / viewRect.height
//        let y = containerRect.origin.x / viewRect.width
//        let width = containerRect.height / viewRect.height
//        let height = containerRect.width / viewRect.width
        sessionManager = AVCaptureSessionManager(captureType: .AVCaptureTypeBoth, scanRect: CGRect.null, success: { (result) in
            if let r = result {
                if self.callBackClosure != nil {
                    self.callBackClosure!(r)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        })
        sessionManager?.showPreViewLayerIn(view: view)
        sessionManager?.isPlaySound = true
        
        let item = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(openPhotoLib))
        navigationItem.rightBarButtonItem = item
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(scanFocus))
        scanView?.addGestureRecognizer(singleTapGesture)
        scanView?.isUserInteractionEnabled = true
    }
    
    @objc func scanFocus(){
        if (sessionManager?.device?.isFocusModeSupported(.autoFocus))!{
            do {
                try sessionManager?.device?.lockForConfiguration()
            }catch{}
            sessionManager?.device?.focusMode = .autoFocus
            sessionManager?.device?.unlockForConfiguration()
        }
    }
    

    //3. 定义一个方法,方法的参数为和swiftBlock类型一致的闭包,并赋值给callBack
    func callBackBlock(_ block: @escaping QrCodeResult) {
        
        callBackClosure = block
    }
    
    override func viewWillAppear(_ animated: Bool) {
        link?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        sessionManager?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        link?.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        sessionManager?.stop()
    }
    
    @objc func scan() {
        scanTop.constant -= 1;
        if (scanTop.constant <= -170) {
            scanTop.constant = 170;
        }
    }
    
    @IBAction func changeState(_ sender: UIButton) {
        torchState = !torchState
        let str = torchState ? "关闭闪光灯" : "开启闪光灯"
        sessionManager?.turnTorch(state: torchState)
        sender.setTitle(str, for: .normal)
    }
    
    
    func showResult(result: String) {
        let alert = UIAlertController.init(title: "扫描结果", message: result, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func openPhotoLib() {
        AVCaptureSessionManager.checkAuthorizationStatusForPhotoLibrary(grant: { 
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }) { 
            let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            })
            let con = UIAlertController(title: "权限未开启",
                                        message: "您未开启相册权限，点击确定跳转至系统设置开启",
                                        preferredStyle: UIAlertControllerStyle.alert)
            con.addAction(action)
            self.present(con, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        sessionManager?.start()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) { 
            self.sessionManager?.start()
            self.sessionManager?.scanPhoto(image: info["UIImagePickerControllerOriginalImage"] as! UIImage, success: { (str) in
                if let result = str {
                    if self.callBackClosure != nil {
                        self.callBackClosure!(result)
                        self.navigationController?.popViewController(animated: false)
                    }
                }else {
                    if self.callBackClosure != nil {
                        self.callBackClosure!("未识别到二维码")
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            })
            
        }
    }


}
