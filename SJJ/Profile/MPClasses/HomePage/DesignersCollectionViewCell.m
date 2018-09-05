//
//  DesignersCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "DesignersCollectionViewCell.h"
#import "DesignerView.h"
#import "HomeConsumerDesignerModel.h"
#import "DesignerMoreView.h"

@interface DesignersCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) DesignerClickBlock myblock;
@end



@implementation DesignersCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        
        DesignerView *view = [[[NSBundle mainBundle] loadNibNamed:@"DesignerView"
                                                                      owner:nil options:nil]lastObject];
//        WS(weakSelf)
//        [view setDataSource:nil calculateBlock:^{
//            [weakSelf clickPersonWithTag:i];
//        }];
////        if (0 == i) {
////            _view1 = view;
////        } else if (1 == i) {
////            _view2 = view;
////        } else {
////            _view3 = view;
////        }
        view.tag = 1000+i;
        view.frame = CGRectMake((SCREEN_WIDTH-30)*i, 0, SCREEN_WIDTH-30, 0.96*(SCREEN_WIDTH-0.1)-15);
        [_scrollView addSubview:view];
        
    }
    DesignerMoreView *moreView = [[[NSBundle mainBundle] loadNibNamed:@"DesignerMoreView"
                                                        owner:nil options:nil]lastObject];
    moreView.tag = 1000+10;
    moreView.frame = CGRectMake((SCREEN_WIDTH-30)*6, 0, SCREEN_WIDTH-30, 0.96*(SCREEN_WIDTH-0.1)-15);
    [_scrollView addSubview:moreView];
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake((SCREEN_WIDTH-30)*7, 0.9*(SCREEN_WIDTH-0.1));
    
}

- (void)setDataSource:(NSMutableArray *)datas calculateBlock:(DesignerClickBlock)block {
    _myblock = block;
    _dataSource = datas;
    WS(weakSelf)
    for (int i = 0; i < datas.count; i++) {
        HomeConsumerDesignerModel *model = _dataSource[i];
        DesignerView *view = (DesignerView *)[self.contentView viewWithTag:1000+i];
        view.frame = CGRectMake((SCREEN_WIDTH-30)*i, 0, SCREEN_WIDTH-30, 0.96*(SCREEN_WIDTH-0.1)-15);
        [view setDataSource:model calculateBlock:^{
            [weakSelf clickPersonWithTag:i];
        }];
    }
    DesignerMoreView *moreView = (DesignerMoreView *)[self.contentView viewWithTag:1000+10];
    moreView.frame = CGRectMake((SCREEN_WIDTH-30)*6, 0, SCREEN_WIDTH-30, 0.96*(SCREEN_WIDTH-0.1)-15);
    [moreView setBlock:^{
        [weakSelf clickPersonWithTag:10];
    }];
    _scrollView.contentSize = CGSizeMake((SCREEN_WIDTH-30)*7, 0.96*(SCREEN_WIDTH-0.1));
    _scrollView.bounces = NO;
    
}

- (void)clickPersonWithTag:(NSInteger)tag {
    if (_myblock) {
        _myblock(tag);
    }
}
@end
