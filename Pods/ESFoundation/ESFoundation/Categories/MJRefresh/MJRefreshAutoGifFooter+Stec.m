//
//  MJRefreshAutoGifFooter+Stec.m
//  Consumer
//
//  Created by jiang on 2017/6/30.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MJRefreshAutoGifFooter+Stec.h"

@implementation MJRefreshAutoGifFooter (Stec)
+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock {
    MJRefreshAutoGifFooter *footer = [super footerWithRefreshingBlock:refreshingBlock];
    
    //    // 设置普通状态的动画图片
    //    [header setImages:idleImages forState:MJRefreshStateIdle];
    //    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    //    [header setImages:pullingImages forState:MJRefreshStatePulling];
    //    // 设置正在刷新状态的动画图片
    //    [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
    // 隐藏刷新状态的文字
    footer.refreshingTitleHidden = YES;
    
    return footer;
}
@end
