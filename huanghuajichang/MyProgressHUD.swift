//
//  MyProgressHUD.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/11/5.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit


class MyProgressHUD: MBProgressHUD {
    
    fileprivate class func showText(text: String, icon: String) {
        let view = viewWithShow()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        let img = UIImage(named: "MBProgressHUD.bundle/\(icon)")
        
        hud.customView = UIImageView(image: img)
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true
        
        hud.hide(animated: true, afterDelay: 1)
    }
    
    class func viewWithShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windowArray = UIApplication.shared.windows
            
            for tempWin in windowArray {
                if tempWin.windowLevel == UIWindowLevelNormal {
                    window = tempWin;
                    break
                }
            }
            
        }
        return window!
    }
    
    class func showStatusInfo(_ info: String) {
        let view = viewWithShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = info
    }
    
    class func dismiss() {
        let view = viewWithShow()
        MBProgressHUD.hide(for: view, animated: true)
        
    }
    
    class func showSuccess(_ status: String) {
        showText(text: status, icon: "success.png")
    }
    
    class func showError(_ status: String) {
        showText(text: status, icon: "error.png")
    }
    
}
