//
//  LoopCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "LoopCollectionViewCell.h"


@interface LoopCollectionViewCell ()<SDCycleScrollViewDelegate>

@property (strong, nonatomic)NSMutableArray *imgArray;
@property (strong, nonatomic)LoopClickBlock myBlock;
@end

@implementation LoopCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _imgArray = [NSMutableArray array];
    
    
}

- (void)setDatasImgArray:(NSMutableArray *)imgArray loopBlock:(LoopClickBlock)loopBlock {
    _myBlock = loopBlock;
    _imgArray = imgArray;
//    NSArray *imgArray = @[@"http://img12.3lian.com/gaoqing02/06/04/21.jpg",
//                          @"http://www.deskcar.com/desktop/else/200994131047/11.jpg",
//                          @"http://www.deskcar.com/desktop/fengjing/2016623223230/6.jpg",
//                          @"http://img18.3lian.com/d/file/201705/02/9ee374e2be1292295b1a616e5b4dcf26.jpg",
//                          @"http://img12.3lian.com/gaoqing02/04/43/49.jpg",
//                          @"http://www.deskcar.com/desktop/fengjing/2017424214222/17.jpg"];
    
    _apView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds delegate:self placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
    _apView.placeholderImage = [UIImage imageNamed:@"HouseDefaultImage"];
    _apView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
//    _apView.titlesGroup = titles;
    _apView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    [self.contentView addSubview:_apView];
    _apView.imageURLStringsGroup = _imgArray;

    //这句可以在任何地方使用，异步下载并展示
//    WS(weakSelf)
//    [_apView startWithTapActionBlock:^(NSInteger index) {
//        if (index < _imgArray.count) {
//            if (weakSelf.myBlock) {
//                weakSelf.myBlock(index);
//            }
//        }
//        
//    }];
    
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    
    if (index < _imgArray.count) {
        if (self.myBlock) {
            self.myBlock(index);
        }
    }
}

@end
