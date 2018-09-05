//
//  ESCollectionView.h
//  EZHome
//
//  Created by shiyawei on 6/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESCollectionView : UIView

@property (nonatomic,strong)    NSArray *datas;

/**
 根基数组获取当前的高度

 @param datas 数组
 @return 高度
 */
+ (CGFloat)getHeight:(NSArray *)datas;


- (void)setDatas:(NSArray *)datas counts:(NSArray *)counts;
@end
