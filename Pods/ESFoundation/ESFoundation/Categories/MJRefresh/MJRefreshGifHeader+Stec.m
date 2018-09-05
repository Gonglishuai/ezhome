//
//  MJRefreshGifHeader+Stec.m
//  Consumer
//
//  Created by jiang on 2017/6/30.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MJRefreshGifHeader+Stec.h"
#import "ESBasic/ESDevice.h"
#import "ESFoundationAssets.h"

@implementation MJRefreshGifHeader (Stec)
+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock {
    
    MJRefreshGifHeader *header = [super headerWithRefreshingBlock:refreshingBlock];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    NSMutableArray *refreshingImages = [NSMutableArray array];
    NSMutableArray *pullingImages = [NSMutableArray arrayWithObjects:[ESFoundationAssets bundleImage:@"header_refresh__0050"], nil];
    for (NSInteger i = 99; i >= 0; i--) {
        UIImage *image = [ESFoundationAssets bundleImage:[NSString stringWithFormat:@"header_refresh__00%02ld", i]];
        [refreshingImages addObject:image];
        if (i >= 70)
        {
            [idleImages addObject:image];
        }
    }
    
    // 设置普通状态的动画图片
    [header setImages:idleImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:pullingImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
    
    //    [header setImages:pullingImages forState:MJRefreshStateWillRefresh];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    //    header.stateLabel.hidden = YES;
    
    return header;
}
- (void)placeSubviews {
    [super placeSubviews];
    //    self.pullingPercent = 0.2;
    self.mj_h = 90;
    self.stateLabel.frame = CGRectMake(0, self.frame.size.height-70, SCREEN_WIDTH, 30);
    self.gifView.frame = CGRectMake(0, CGRectGetMaxY(self.stateLabel.frame), 40, 40);
    self.gifView.center = CGPointMake(SCREEN_WIDTH/2, self.stateLabel.center.y+30);
}
@end

