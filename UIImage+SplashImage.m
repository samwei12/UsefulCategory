//
//  UIImage+SplashImage.m
//  MagicCam
//
//  Created by samwei12 on 15/12/12.
//  Copyright © 2015年 Xiaosen. All rights reserved.
//

#import "UIImage+SplashImage.h"

@implementation UIImage (SplashImage)

+ (NSString *)splashImageNameForOrientation:(UIInterfaceOrientation)orientation
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;

    NSString *viewOrientation = @"Portrait";

    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        viewSize = CGSizeMake(viewSize.height, viewSize.width);
        viewOrientation = @"Landscape";
    }

    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];

    for (NSDictionary *dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

+ (UIImage*)splashImageForOrientation:(UIInterfaceOrientation)orientation
{
    NSString *imageName = [self splashImageNameForOrientation:orientation];
    UIImage *image = [UIImage imageNamed:imageName];
    return image;
}

@end
