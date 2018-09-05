//
//  ESFoundationAssets.m
//  ESFoundation
//
//  Created by jiang on 2017/11/7.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "ESFoundationAssets.h"

@implementation ESFoundationAssets

+ (UIImage *)bundleImage:(NSString *)imgName {
    UIImage *image = [UIImage imageNamed:imgName inBundle:[self hostBundle] compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    } else {
        return nil;
    }
    
}
    
+(NSBundle *)hostBundle {
    NSBundle *podbundle = [NSBundle bundleForClass:[ESFoundationAssets class]];
    NSURL *bundleURL = [podbundle URLForResource:@"ESFoundation" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}
    
@end
