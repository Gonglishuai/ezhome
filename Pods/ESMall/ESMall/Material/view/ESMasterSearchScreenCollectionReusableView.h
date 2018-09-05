//
//  ESMasterSearchScreenCollectionReusableView.h
//  Mall
//
//  Created by jiang on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMasterSearchScreenCollectionReusableView : UICollectionReusableView
- (void)setScreenArray:(NSArray *)screenArray removeBlock:(void(^)(NSInteger index))removeBlock clearBlock:(void(^)(void))clearBlock;
@end
