//
//  PictureVisitControl.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/14.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class PictureVisitControl: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var currentIndex:Int?
    var pictureData:[Any]?
    
    
    init(index:Int,images:[Any]) {
        
        //先初始化本类属性,在初始化父类
        currentIndex = index
        pictureData = images
        super.init(nibName: nil, bundle: nil)
        setUpUI()
        view.backgroundColor = .white
    }
    
    private func setUpUI(){
        view.addSubview(collectionView)
        view.addSubview(closebtn)
        view.addSubview(SaveBtn)
        
        //设置数据源
        collectionView.dataSource = self;
        
        collectionView.register(PictureVisitControlCell.self, forCellWithReuseIdentifier: "item")
        
        setlayoutContains()
        
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.scrollToItem(at: IndexPath.init(row: currentIndex!, section: 0), at: UICollectionViewScrollPosition.right, animated: false)
    }
    
    private func setlayoutContains(){
        
        closebtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-30)
            make.left.equalTo(20)
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
        
        SaveBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-30)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
    }
    @objc private func closeAction(){
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func SaveAction(){
        let index = collectionView.indexPathsForVisibleItems.last!
        let cell:PictureVisitControlCell = collectionView.cellForItem(at: index) as! PictureVisitControlCell
        
        //保存图片
        let img = cell.IMg.image
        let isEqual = self.isExistInPhotoAlbum(selectedImgView: cell.IMg)
        if isEqual {
            MyProgressHUD.showError("相册中已存在该图片")
        } else {
            PHPhotoLibrary.shared().performChanges({
                let _ = PHAssetChangeRequest.creationRequestForAsset(from: img!)
            }) { (success, error) in
                if success {
                    DispatchQueue.main.async() {
                        MyProgressHUD.showSuccess("保存成功")
                    }
                } else {
                    DispatchQueue.main.async() {
                        MyProgressHUD.showError("保存失败")
                    }
                }
            }
        }
    }
    
    /// 相册中是否已存在图片
    ///
    /// - Returns: 是否存在图片的状态布尔值
    func isExistInPhotoAlbum(selectedImgView:UIImageView) -> Bool {
        var imageIsEqual = false
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)] //按创建日期排序
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions) //获取所有照片
        
        //对所有照片进行遍历
        allPhotos.enumerateObjects({ (asset, index, stop) in
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            //将照片的元数据转换成UIImage对象
            imageManager.requestImage(for: asset, targetSize: CGSize(width: selectedImgView.bounds.size.width, height: selectedImgView.bounds.size.height), contentMode: .default, options: options, resultHandler: { (image, _: [AnyHashable : Any]?) in
                //对比两张图片是否相同
                let result = self.isEqualImage(imageOne: image!, imageTwo: selectedImgView.image!)
                if result {
                    imageIsEqual = true
                    stop.pointee = true
                }
            })
        })
        return imageIsEqual
    }
    
    
    //1.缩小图片尺寸
    func scaleToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        img.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    //2.简化色彩 将图片转换成灰度图片
    func getGrayImage(sourceImage: UIImage) -> UIImage {
        let imageRef: CGImage = sourceImage.cgImage!
        let width: Int = imageRef.width
        let height: Int = imageRef.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: width, height: height)
        context.draw(imageRef, in: rect)
        
        let outPutImage: CGImage = context.makeImage()!
        
        let newImage: UIImage = UIImage.init(cgImage: outPutImage)
        
        return newImage
    }
    
    //3. 计算平均值, 比较像素的灰度
    func pHashValueWithImage(image: UIImage) -> NSString {
        let pHashString = NSMutableString()
        let imageRef = image.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var sum: Int = 0
        for i in 0..<width * height {
            if data[i] != 0 {
                sum = sum + Int(data[i])
            }
        }
        let avr = sum / (width * height)
        for i in 0..<width * height {
            if Int(data[i]) >= avr {
                pHashString.append("1")
            } else {
                pHashString.append("0")
            }
        }
        return pHashString
    }
    
    //4.计算哈希值 如果不相同的数据位不超过5，就说明两张图片很相似；如果大于10，就说明这是两张不同的图片。
    func getDifferentValueCountWithString(str1: NSString, str2: NSString) -> NSInteger {
        var diff: NSInteger = 0
        let s1 = str1.utf8String!
        let s2 = str2.utf8String!
        for i in 0..<str1.length {
            if s1[i] != s2[i] {
                diff += 1
            }
        }
        return diff
    }
    
    /// 比较两个图片是否相同, 这里比较尺寸为20*20
    ///
    /// - Parameters:
    ///   - imageOne: 图片1
    ///   - imageTwo: 图片2
    /// - Returns: 是否相同的布尔值
    func isEqualImage(imageOne: UIImage, imageTwo: UIImage) -> Bool {
        var equalResult = false
        let mImageOne = self.getGrayImage(sourceImage: self.scaleToSize(img: imageOne, size: CGSize(width: 20, height: 20)))
        let mImageTwo = self.getGrayImage(sourceImage: self.scaleToSize(img: imageTwo, size: CGSize(width: 20, height: 20)))
        let diff = self.getDifferentValueCountWithString(str1: self.pHashValueWithImage(image: mImageOne), str2: self.pHashValueWithImage(image: mImageTwo))
//        print(diff)
        if diff > 10 {
            equalResult = false
        } else {
            equalResult = true
        }
        return equalResult
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private lazy var collectionView:UICollectionView = UICollectionView(frame:CGRect.zero, collectionViewLayout: PicturePrepareLayout())
    
    private lazy var closebtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.darkGray
        btn.addTarget(self, action: #selector(closeAction), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    
    private lazy var SaveBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.darkGray
        btn.addTarget(self, action: #selector(SaveAction), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    
}

class PicturePrepareLayout:UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = UIScreen.main.bounds.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false;
        collectionView?.allowsMultipleSelection = true
    }
}


extension PictureVisitControl:UICollectionViewDataSource,PictureVisitControlCellDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PictureVisitControlCell
        cell.PictureVisitDelegate = self
        cell.imageURL = pictureData?[indexPath.row] as Any
        return cell
    }
    
    func TapPhotoCloseDismiss(cell: PictureVisitControlCell) {
        dismiss(animated: true, completion: nil)
    }
    
}
