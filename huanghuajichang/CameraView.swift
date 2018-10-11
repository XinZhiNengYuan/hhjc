//
//  CameraView.swift
//  XinaoEnergy
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class CameraView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var cameraButton : UIButton!
    var photoButton : UIButton!
    var image : UIImageView!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        cameraButtonMethods()
        photoButtonMethods()
        imageMethods()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cameraButtonMethods(){
        cameraButton = UIButton(type: UIButtonType.custom)
        cameraButton.frame = CGRect(x: 20, y: 400, width: 100, height: 40)
        cameraButton.setTitle("调用相机", for: UIControlState.normal)
        cameraButton.backgroundColor = UIColor.blue
        self.addSubview(cameraButton)
    }
    
    func photoButtonMethods(){
        photoButton = UIButton(type: UIButtonType.custom)
        photoButton.frame = CGRect(x: 255, y: 400, width: 100, height: 40)
        photoButton.backgroundColor = UIColor.blue
        photoButton.setTitle("调用相册",for:UIControlState.normal)
        self.addSubview(photoButton)
    }
    func imageMethods(){
        image = UIImageView()
        image.image = UIImage(named: "image")
        image.frame = CGRect(x: 20, y: 40, width: 335, height: 335)
        self.addSubview(image)
    }
    
}

