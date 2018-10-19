//
//  CellFlowLayout.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/19.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class CellFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        //尺寸
        itemSize = (collectionView?.bounds.size)!
        //间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        //滚动方向
        scrollDirection = .horizontal
    }
}
