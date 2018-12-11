//
//  UIButton+EnlargeTouchArea.h
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/10.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeTouchArea)

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

- (void)setEnlargeEdge:(CGFloat) size;

@end


