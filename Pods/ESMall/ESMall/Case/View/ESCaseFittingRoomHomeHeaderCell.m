
#import "ESCaseFittingRoomHomeHeaderCell.h"
#import "ESFittingRoomBannerModel.h"
#import "SDCycleScrollView.h"

@interface ESCaseFittingRoomHomeHeaderCell ()

@end

@implementation ESCaseFittingRoomHomeHeaderCell
{
    BOOL _needRefresh;
    SDCycleScrollView *_apView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code

    _needRefresh = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getFittingRoomHeaderDataWithIndexPath:)])
    {
        if (!_needRefresh || _apView)
        {
            return;
        }
        
        _needRefresh = NO;
        
        NSArray *images = [self.cellDelegate getFittingRoomHeaderDataWithIndexPath:indexPath];
        if (!images
            || ![images isKindOfClass:[NSArray class]])
        {
            return;
        }
        
        CGRect rect = CGRectMake(
                                 0,
                                 0,
                                 CGRectGetWidth(self.contentView.frame),
                                 CGRectGetHeight(self.contentView.frame) - 10.0f
                                 );
        _apView = [SDCycleScrollView
                   cycleScrollViewWithFrame:rect
                   delegate:(id)self.cellDelegate
                   placeholderImage:[UIImage imageNamed:@"1-3_banner"]];
        _apView.placeholderImage = [UIImage imageNamed:@"1-3_banner"];
        _apView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        _apView.currentPageDotColor = [UIColor whiteColor];
        _apView.autoScrollTimeInterval = 6.0f;//自动轮播的时间
        [self.contentView addSubview:_apView];
        
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSInteger i = 0; i < images.count; i++)
        {
            ESFittingRoomBannerModel *model = images[i];
            if ([model isKindOfClass:[ESFittingRoomBannerModel class]]
                && [model.imageUrl isKindOfClass:[NSString class]])
            {
                [arrM addObject:model.imageUrl];
            }
        }
        _apView.imageURLStringsGroup = [arrM copy];
        
        if ([self.cellDelegate respondsToSelector:@selector(loopViewDidCreated:)])
        {
            [self.cellDelegate loopViewDidCreated:_apView];
        }
    }
}

@end
