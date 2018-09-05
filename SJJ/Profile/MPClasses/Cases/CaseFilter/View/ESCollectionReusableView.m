//
//  ESCollectionReusableView.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCollectionReusableView.h"
#import "ESCollectionViewLayoutAttributes.h"

@implementation ESCollectionReusableView
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[ESCollectionViewLayoutAttributes class]]) {
        ESCollectionViewLayoutAttributes *attr = (ESCollectionViewLayoutAttributes *)layoutAttributes;
        self.backgroundColor = attr.backgroundColor;
    }
}
@end
