//
//  ESLiWuLoopCell.m
//  Mall
//
//  Created by 焦旭 on 2017/9/10.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuLoopCell.h"
#import "SDCycleScrollView.h"

@interface ESLiWuLoopCell()<SDCycleScrollViewDelegate>
@property (nonatomic, strong) SDCycleScrollView *cycView;
@end

@implementation ESLiWuLoopCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.cycView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, width, height)
                                                      delegate:self
                                              placeholderImage:[UIImage imageNamed:@"1-3_banner"]];
    self.cycView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    self.cycView.currentPageDotColor = [UIColor whiteColor];
    self.cycView.autoScrollTimeInterval = 6.0f;
    [self.contentView addSubview:self.cycView];
}

- (void)updateCell {
    if ([self.delegate respondsToSelector:@selector(getLoopImgUrls)]) {
        self.cycView.imageURLStringsGroup = [self.delegate getLoopImgUrls];
        if ([self.delegate getLoopImgUrls].count > 0) {
            self.cycView.autoScroll = YES;
            self.cycView.infiniteLoop = YES;
            [self.cycView refreshTimer];
        }
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(selectLoopCellAtIndex:)]) {
        [self.delegate selectLoopCellAtIndex:index];
    }
}

- (void)dealloc {
    [self.cycView invalidateTimer];
}
@end
