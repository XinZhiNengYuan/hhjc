//
//  MaxCardViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/21.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class MaxCardViewController: AddNavViewController {

    let dataArray = [["label":"ios二维码","url":"http://123.58.243.29:2466/uploadImage/app_image/ios.jpg"],["label":"安卓二维码","url":"http://123.58.243.29:2466/uploadImage/app_image/andriod.jpg"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "APP二维码"
        self.view.backgroundColor = UIColor.white
        
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI() {
        for (index, value) in  dataArray.enumerated() {
            print(value as Any)
            let label = UILabel.init()
            //        label.backgroundColor = UIColor.gray
            label.text = value["label"]
            
            label.font = UIFont.systemFont(ofSize: 14)
            //        label.textColor = UIColor.red
            let text:NSString = label.text! as NSString
            let size = CGSize(width: 250, height: 20)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = text.boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: label.font], context: nil)
            
            print("height:\(estimatedFrame.height),width:\(estimatedFrame.width)")
            label.frame = CGRect(x: (kScreenWidth-estimatedFrame.width)/2, y: CGFloat(260*index+56), width: estimatedFrame.width, height: 20)
            self.view.addSubview(label)
            
            let imageV = UIImageView(frame: CGRect(x: 90, y: CGFloat(260*index+86), width: 200, height: 200))
            //        imageV.layer.borderWidth = 5
            //        imageV.layer.borderColor = UIColor.red.cgColor
            imageV.dowloadFromServer(link:value["url"]! as String, contentMode: .scaleAspectFill)
            self.view.addSubview(imageV)
        }
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

//UIImageView extension扩展方法，使用了URLSession对象async异步下载网络图片，并设置到UIImageView对象中

extension UIImageView {
    func dowloadFromServer(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async() {
                        self.image = UIImage(named: "默认图片")
                    }
                    return 
                }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func dowloadFromServer(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        dowloadFromServer(url: url, contentMode: mode)
    }
}
/*
 根居内容自适应宽高
 方法1：限制宽高，可设置行间距，计算准确
 方法2：比方法1多了限制行数功能。
 */
extension String {
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedStringKey.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        
        return size
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize {
        if lines < 0 {
            return .zero
        }
        
        let size = boundingRect(with: constrainedSize, font: font, lineSpacing: lineSpacing)
        if lines == 0 {
            return size
        }
        
        let currentLineSpacing = (lineSpacing == nil) ? (font.lineHeight - font.pointSize) : lineSpacing!
        let maximumHeight = font.lineHeight*CGFloat(lines) + currentLineSpacing*CGFloat(lines - 1)
        if size.height >= maximumHeight {
            return CGSize(width: size.width, height: maximumHeight)
        }
        
        return size
    }
}

extension UILabel {
    
    // 设置`numberOfLines = 0`的原因：
    // 配合方法`func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize`使用，可以很好的解决不能正常显示限制行数的问题；
    // 如果为label设置了限制行数（大于0的前提），使用上面的计算方法（带行间距），同时字符串的实际行数大于限制行数，这时候的高度会使label不能正常显示。
    func setText(with normalString: String, lineSpacing: CGFloat?, frame: CGRect) {
        self.frame = frame
        self.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        if lineSpacing != nil {
            if (frame.height - font.lineHeight) <= lineSpacing! {
                paragraphStyle.lineSpacing = 0
            } else {
                paragraphStyle.lineSpacing = lineSpacing!
            }
        }
        let attributedString = NSMutableAttributedString(string: normalString)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes([NSAttributedStringKey.font: font], range: range)
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
        
        self.attributedText = attributedString
    }
}
