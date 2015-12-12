//
//  UIImage+fixOrientation.h
//  MagicCam
//
//  Created by samwei12 on 15/10/23.
//  Copyright © 2015年 Xiaosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (fixOrientation)
/**
 *  @author samwei12, 15-10-23 16:10:46
 *
 *  由于保存下来的图片在windows 或者 mac 上显示不相同,因此,做好旋转之后再进行保存
 */
- (UIImage *)fixOrientation;

@end
