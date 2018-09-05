//
//  ESMallAssets.m
//  ESMall
//
//  Created by 焦旭 on 2017/11/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMallAssets.h"

@implementation ESMallAssets
+ (UIImage *)bundleImage:(NSString *)imgName {
    UIImage *image = [UIImage imageNamed:imgName inBundle:[self hostBundle] compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    } else {
        return nil;
    }
    
}

+(NSBundle *)hostBundle {
    NSBundle *podbundle = [NSBundle bundleForClass:[ESMallAssets class]];
    NSURL *bundleURL = [podbundle URLForResource:@"ESMall" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}
@end
