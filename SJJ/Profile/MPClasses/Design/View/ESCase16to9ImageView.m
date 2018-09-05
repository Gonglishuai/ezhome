//
//  ESCase16to9ImageView.m
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCase16to9ImageView.h"
#import "SDCycleScrollView.h"
#import "UILabel+Size.h"
#import "EZHome-Swift.h"


@interface ESCase16to9ImageView()<SDCycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomTypeCode;
@property (weak, nonatomic) IBOutlet UILabel *description_case;
@property (strong, nonatomic)SDCycleScrollView *apView;
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIButton *allPic;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@end

@implementation ESCase16to9ImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel2d:(ESCase2DImageModel *)model2d {
    _model2d = model2d;
    self.roomTypeCode.text = model2d.typeName;
    self.description_case.text = model2d.description_Space;
    if (_apView == nil) {
        _apView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.56) delegate:self placeholderImage:[UIImage imageNamed:@"default_banner"]];
        _apView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _apView.pageControlDotSize = CGSizeMake(5, 5);
        _apView.currentPageDotColor = [UIColor whiteColor];
        _apView.showPageControl = NO;
        [self.bannerView addSubview:_apView];
        [self.bannerView sendSubviewToBack:_apView];
    }
    NSMutableArray *imgArr = [NSMutableArray array];
    for (ESCase2DItemModel *item in model2d.renderImgs) {
        [imgArr addObject:item.link];
    }
    _apView.imageURLStringsGroup = imgArr;
    _numLab.text = [NSString stringWithFormat:@"%ld/%lu",(long)1,(unsigned long)model2d.renderImgs.count];
    _numLab.hidden = imgArr.count <= 1;
    _numLab.layer.masksToBounds = YES;
    _numLab.layer.cornerRadius = 4;
}

-(void)setModel:(ESCaseSpaceDetails *)model {
    _model = model;
    ESRoomType *roomType = [[ESRoomType alloc] init];
    self.roomTypeCode.text = roomType.roomTypesDict[model.roomTypeCode];
    int colorRgb = roomType.colorStyleDict[model.roomTypeCode];
    self.colorLabel.backgroundColor = ColorFromRGA(colorRgb, 1);
    self.description_case.text = model.description_Space;
    if (_apView == nil) {
        _apView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.56) delegate:self placeholderImage:[UIImage imageNamed:@"default_banner"]];
        //_apView.autoScroll = NO;
        _apView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _apView.pageControlDotSize = CGSizeMake(5, 5);
        _apView.currentPageDotColor = [UIColor whiteColor];
        _apView.showPageControl = NO;
        [self.bannerView addSubview:_apView];
        [self.bannerView sendSubviewToBack:_apView];
    }
    _apView.imageURLStringsGroup = model.imageUrls;
    //_apView.titleLabelTextAlignment = NSTextAlignmentCenter;
    //_apView.titlesGroup = model.isHave360Urls;
    _numLab.text = [NSString stringWithFormat:@"%ld/%lu",(long)1,(unsigned long)model.imageUrls.count];
    _allPic.hidden = model.isHave360Urls.count == 0;
    _numLab.hidden = model.imageUrls.count <= 1;
    _allPic.layer.masksToBounds = YES;
    _allPic.layer.cornerRadius = 20;
    _numLab.layer.masksToBounds = YES;
    _numLab.layer.cornerRadius = 4;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    ESCaseRenderImage *imageArray = self.model.renderImgs[index];
    if (![imageArray.photo360Url isEqualToString:@""] && [self.delegate respondsToSelector:@selector(openPhoto360Url:)]) {
        [self.delegate openPhoto360Url:imageArray.photo360Url];
        NSLog(@"360kanfang--%@",imageArray.photo360Url);
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{

    _numLab.text = [NSString stringWithFormat:@"%ld/%lu",index+1,(unsigned long)
                    _myStyleType == CaseStyleType2D ? _model2d.renderImgs.count : _model.imageUrls.count];
}

+ (CGFloat)currentImageViewHeight:(NSString*)String {

    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT);
    CGRect textRect = [String boundingRectWithSize:maximumLabelSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                              context:nil];
    CGFloat h = textRect.size.height > 60 ? 60 : textRect.size.height;
    return h + SCREEN_WIDTH * 0.56 + 60;
}

@end
