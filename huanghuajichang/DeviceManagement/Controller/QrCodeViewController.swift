//
//  QrCodeViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/8/7.
//  Copyright © 2018年 zx. All rights reserved.
//
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


import UIKit

import AVFoundation
import SwiftyJSON
import WebKit

class QrCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    
    
    var session:AVCaptureSession!
    
    var screenWidth : CGFloat!
    
    var screenHeight:CGFloat!
    
    let qrCodeService = QrCodeService()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        screenWidth = self.view.bounds.width
        
        screenHeight = self.view.bounds.height
        initPageStyle()
        
    }
    
    @objc func initPageStyle(){
        
        setView()
        
        setCamera()
    }
    
    
    //设置除了扫描区以外的视图
    
    func setView(){
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth/2-100, height: screenHeight))
        
        leftView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        self.view.addSubview(leftView)
        
        let backButton = UIButton(frame: CGRect(x: 40, y: 40, width: 40, height: 40))
        backButton.setImage(UIImage(named: "返回"), for: UIControlState.normal)
        backButton.layer.backgroundColor = UIColor.green.cgColor
        backButton.layer.cornerRadius = 20
        backButton.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        self.view.addSubview(backButton)
        
        
        let rightView = UIView(frame: CGRect(x: screenWidth/2+100, y: 0, width: screenWidth-(screenWidth/2+100), height: screenHeight))
        
        rightView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        self.view.addSubview(rightView)
        
        
        
        let topView = UIView(frame: CGRect(x: screenWidth/2-100, y: 0, width: 200, height: screenHeight/2-100))
        
        topView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        self.view.addSubview(topView)
        
        
        
        let bottomView = UIView(frame: CGRect(x: screenWidth/2-100, y: screenHeight/2+100, width: 200, height: screenHeight/2-100))
        
        bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        self.view.addSubview(bottomView)
        
        
        
    }
    
    //MARK: 返回按钮点击事件
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    //设置相机
    
    func setCamera(){
        
        //获取摄像设备
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            
            return
            
        }
        
        do {
            
            //创建输入流
            
            let input =  try AVCaptureDeviceInput(device: device)
            
            //创建输出流
            
            let output = AVCaptureMetadataOutput()
            
            
            
            //设置会话
            
            session = AVCaptureSession()
            
            
            
            //连接输入输出
            
            if session.canAddInput(input){
                
                session.addInput(input)
                
            }
            
            if session.canAddOutput(output){
                
                
                
                session.addOutput(output)
                
                
                
                //设置输出流代理，从接收端收到的所有元数据都会被传送到delegate方法，所有delegate方法均在queue中执行
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                //设置扫描二维码类型
                
                output.metadataObjectTypes = [ AVMetadataObject.ObjectType.qr]
                
                //扫描区域
                
                //rectOfInterest 属性中x和y互换，width和height互换。
                
                output.rectOfInterest = CGRect(x: 0, y: 0, width: screenHeight, height: screenWidth)
                
            }
            
            
            
            
            
            //捕捉图层
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            previewLayer.videoGravity = .resizeAspectFill
            
            previewLayer.frame = self.view.layer.bounds
            
            self.view.layer.insertSublayer(previewLayer, at: 0)
            
            
            
            //持续对焦
            
            if device.isFocusModeSupported(.continuousAutoFocus){
                
                try  input.device.lockForConfiguration()
                
                input.device.focusMode = .continuousAutoFocus
                
                input.device.unlockForConfiguration()
                
            }
            
            session.startRunning()
            
            
            
        } catch  {
            
            
            
        }
        
        
        
    }
    
    
    
    
    
    //扫描完成的代理
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        session?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            
            
            
            let resultStr = readableObject.stringValue!
            
            let userId = userDefault.string(forKey: "userId")
            let token = userDefault.string(forKey: "userToken")
            let contentData : [String : Any] = ["method":"checkEquipmentByCode","info":["code":resultStr],"user_id":userId as Any,"token":token as Any]
            
            qrCodeService.getQrCode(contentData: contentData, finishedData: { (resultData) in
                if resultData["status"].stringValue == "success"{
                    if resultData["data"].stringValue == "101"{
                        let alertView = UIAlertController(title: "提示", message: "非法二维码", preferredStyle: UIAlertControllerStyle.alert)
                        let yes = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: {
                            action in
                            self.dismiss(animated: false, completion: nil)
                        })
                        alertView.addAction(yes)
                        self.present(alertView, animated: false, completion: nil)
                    }else if resultData["data"].stringValue == "102"{//未绑定的新设备
                        let addDeviceManagementViewController = AddDeviceManagementViewController()
                        addDeviceManagementViewController.eqCode = resultStr
                        let navigationView = UINavigationController.init(rootViewController: addDeviceManagementViewController)
                        UINavigationBar.appearance().barTintColor = UIColor(red: 41/255, green: 105/255, blue: 222/255, alpha: 1) //修改导航栏背景色
                        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] //为导航栏设置字体颜色等
                        self.present(navigationView, animated: true, completion: nil)
                    }else{//已经绑定过的设备
                        let deviceDetailViewController = DeviceDetailViewController()
                        deviceDetailViewController.eqCode = resultStr
                        self.navigationController?.pushViewController(deviceDetailViewController, animated: true)
                    }
                }else{
                     self.present(windowAlert(msges: "暂未获取到有用信息！"), animated: false, completion: nil)
                }
            }) { (errorData) in
               self.present(windowAlert(msges: "网络请求失败"), animated: false, completion: nil)
            }
//            let url = URL(string: str)
//
//            //用网页打开扫描的信息
//
//            if #available(iOS 10, *){
//
//                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//
//            }else{
//
//                UIApplication.shared.openURL(url!)
//
//            }
            
        }
        
        
        
    }
    
}
