//
//  CheckMoreReusableView.h
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckMoreReusableView : UICollectionReusableView
- (void)setBlock:(void(^)(void))block;
@end
