//
//  ESCase4to3ImageView.m
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCase4to3ImageView.h"
#import "SDCycleScrollView.h"

@interface ESCase4to3ImageView ()<SDCycleScrollViewDelegate>
@property (nonatomic,strong)    SDCycleScrollView *apView;
@property (weak, nonatomic) IBOutlet UILabel *description_case;

@property (nonatomic,strong)    NSMutableArray *aerials;
@end

@implementation ESCase4to3ImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.aerials = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAerialViewModel:(ESCaseDetailModel *)aerialViewModel {

    _aerialViewModel = aerialViewModel;
    if (_apView == nil) {
        _apView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.75) delegate:self placeholderImage:[UIImage imageNamed:@"default_banner"]];
        //_apView.autoScroll = NO;
        _apView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _apView.pageControlDotSize = CGSizeMake(5, 5);
        _apView.currentPageDotColor = [UIColor whiteColor];
        _apView.showPageControl = NO;
        [self addSubview:_apView];
        [self sendSubviewToBack:_apView];
    }
    
    
    
    for (ESCaseSpaceDetails *detailS in aerialViewModel.spaceDetails) {
        if ([detailS.roomTypeCode isEqualToString:@"other"]){
            for (ESCaseRenderImage *renderImg in detailS.renderImgs){
                if ([renderImg.renderType isEqualToString:@"aerial"]){
                    [self.aerials addObject:renderImg.photoUrl];
                }
            }
        }
    }
    if (self.aerials.count > 0) {
        _apView.imageURLStringsGroup = self.aerials;
    }
    
    _numLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)1,(long)self.aerials.count];
    _numLab.hidden = self.aerials.count <= 1;

    _numLab.layer.masksToBounds = YES;
    _numLab.layer.cornerRadius = 4;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{
    
    if (self.aerials.count > 0) {
        _numLab.text = [NSString stringWithFormat:@"%ld/%lu",index+1,(unsigned long) self.aerials.count];
    }
}



+ (BOOL)getCellHeightModel:(ESCaseDetailModel *)aerialViewModel {
    for (ESCaseSpaceDetails *detailS in aerialViewModel.spaceDetails) {
        if ([detailS.roomTypeCode isEqualToString:@"other"]){
            for (ESCaseRenderImage *renderImg in detailS.renderImgs){
                if ([renderImg.renderType isEqualToString:@"aerial"]){
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
