//
//  UIImage+SplashImage.h
//  MagicCam
//
//  Created by samwei12 on 15/12/12.
//  Copyright © 2015年 Xiaosen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Category on `UIImage` to access the splash image. support Portrait or Landscape
 **/
@interface UIImage (SplashImage)
/**
 * Return the name of the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The name of the splash image.
 **/
+ (NSString *)splashImageNameForOrientation:(UIInterfaceOrientation)orientation;

/**
 * Returns the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The splash image.
 **/
+ (UIImage*)splashImageForOrientation:(UIInterfaceOrientation)orientation;
@end
