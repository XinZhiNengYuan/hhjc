//
//  PictureVisitControlCell.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/14.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Kingfisher

protocol PictureVisitControlCellDelegate:NSObjectProtocol {
    func TapPhotoCloseDismiss(cell:PictureVisitControlCell)
}

class PictureVisitControlCell: UICollectionViewCell {
    
    private lazy var scrollView:UIScrollView = UIScrollView()
    lazy var IMg:UIImageView = UIImageView()
    
    weak var PictureVisitDelegate : PictureVisitControlCellDelegate?
    
    var imageURL:Any?{
        didSet{
            if imageURL! as? NSURL != nil {//传入的是url
                if (NSString(string: (imageURL! as! NSURL).absoluteString!)).hasPrefix("http") {//网络图片
                    reSetPosion()
                    
                    IMg.kf.setImage(with: imageURL as! URL, placeholder:UIImage(named: "默认图片"), options: nil, progressBlock: nil) { (Result) in
                        
                        //调整图片位置
                        self.setImgViewPosion()
                    }
                }
            }else if imageURL! as? String != nil {//传入的是str
                if ((imageURL as! NSString)).hasPrefix("http") {//网络图片
                    reSetPosion()
                    
                    IMg.kf.setImage(with: (NSURL.init(string: imageURL as! String))! as URL, placeholder:UIImage(named: "默认图片"), options: nil, progressBlock: nil) { (Result) in
                        
                        //调整图片位置
                        self.setImgViewPosion()
                    }
                }
            } else if imageURL! as? UIImage != nil {//uiimage对象
                reSetPosion()
                
                IMg.image = imageURL as? UIImage
                //调整图片位置
                self.setImgViewPosion()
            }
        }
    }
    
    //调整图片显示的位置
    private  func setImgViewPosion(){
        let size = self.disPlaySize(image: IMg.image!)
        
        if size.height < kScreenHeight{
            self.IMg.frame = CGRect.init(origin: CGPoint.zero, size: size)
            
            //处理居中显示
            let y = (UIScreen.main.bounds.height - size.height) * 0.5
            self.scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: -y, right: 0)
        }else
        {
            self.IMg.frame = CGRect.init(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
        }
        
    }
    
    
    //重置scrollerView和imageView的属性
    private func reSetPosion(){
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = CGSize.zero
        
        //重置imageview的属性
        IMg.transform = CGAffineTransform.identity
        
    }
    
    
    private func disPlaySize(image:UIImage)->CGSize{
        
        let scale = image.size.height / image.size.width
        let width = UIScreen.main.bounds.width
        let height = width * scale
        return CGSize(width: width, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        SetUpUI()
        
    }
    
    private func  SetUpUI(){
        contentView.addSubview(scrollView)
        scrollView.addSubview(IMg)
        
        //添加布局
        scrollView.frame = UIScreen.main.bounds
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.5
        IMg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        IMg.addGestureRecognizer(tap)
    }
    
    
    /// 点击图片关闭控制器
    @objc private func close(){
        PictureVisitDelegate?.TapPhotoCloseDismiss(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PictureVisitControlCell:UIScrollViewDelegate{
    
    //告诉系统需要缩放的view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return IMg;
    }
    
    
    //重新调整配图的位置
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        var offSetX = (UIScreen.main.bounds.width - (view?.frame.width)!) * 0.5
        var offSetY = (UIScreen.main.bounds.height - (view?.frame.height)!) * 0.5
        
        offSetX = offSetX < 0 ? 0: offSetX
        offSetY = offSetY < 0 ? 0: offSetY
        
        scrollView.contentInset = UIEdgeInsets(top: offSetY, left: offSetX, bottom: offSetY, right: offSetX)
        
        
    }
    
}
