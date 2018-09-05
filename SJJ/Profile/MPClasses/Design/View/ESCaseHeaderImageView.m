//
//  ESCaseHeaderImageView.m
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCaseHeaderImageView.h"
#import "SDCycleScrollView.h"
#import "ESCaseRenderImage.h"
#import "UIImageView+WebCache.h"

@interface ESCaseHeaderImageView()<SDCycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *caseName;
@property (strong, nonatomic)SDCycleScrollView *apView;
@end

@implementation ESCaseHeaderImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(ESCaseDetailModel *)model {
    _model = model;
    NSString *url2d = @"";
    self.caseName.text = model.name;
    if (_myStyleType == CaseStyleType2D) {
        for (ESCase2DImageModel *imgModel in model.roomImages) {
            for (ESCase2DItemModel *item in imgModel.renderImgs) {
                if (item.isPrimary) {
                    url2d = item.link;
                    break;
                }
            }
        }
    }
    
    [_headImg sd_setImageWithURL:[NSURL URLWithString: _myStyleType == CaseStyleType2D ? url2d : model.caseCover] placeholderImage:[UIImage imageNamed:@"default_banner"]];
    _linkBtn.layer.masksToBounds = YES;
    _linkBtn.layer.cornerRadius = 20;
    _linkBtn.hidden = _myStyleType == CaseStyleType2D;
    [_linkBtn addTarget:self action:@selector(to3DDetailVC) forControlEvents:UIControlEventTouchUpInside];
    /*if (_apView == nil) {
        _apView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds delegate:self placeholderImage:[UIImage imageNamed:@"default_banner"]];
        _apView.autoScroll = NO;
        _apView.showPageControl = NO;
        _apView.titleLabelTextAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_apView];
        //[self.contentView sendSubviewToBack:_apView];
    }
    _apView.imageURLStringsGroup = @[model.caseCover];
    _apView.titlesGroup = model.naviPanos.isHave360Urls;*/
}

-(void)to3DDetailVC {
    for (ESCaseRenderImage *imageArray in self.model.naviPanos.renderImgs) {
        if (imageArray.selectStatus == 1) {
            if (![imageArray.photo360Url isEqualToString:@""] && [self.delegate respondsToSelector:@selector(openPhoto360Url:)]) {
                [self.delegate openPhoto360Url:imageArray.photo360Url];
                NSLog(@"360kanfang--%@",imageArray.photo360Url);
            }
            break;
        }
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    ESCaseRenderImage *imageArray = self.model.naviPanos.renderImgs[index];
    if (![imageArray.photo360Url isEqualToString:@""] && [self.delegate respondsToSelector:@selector(openPhoto360Url:)]) {
        [self.delegate openPhoto360Url:imageArray.photo360Url];
        NSLog(@"360kanfang--%@",imageArray.photo360Url);
    }
}

@end
