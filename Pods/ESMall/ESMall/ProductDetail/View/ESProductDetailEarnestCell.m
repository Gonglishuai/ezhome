
#import "ESProductDetailEarnestCell.h"
#import "ESProductDetailEarnestModel.h"

@interface ESProductDetailEarnestCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UIView *unstartView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *startView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *priceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *placeQuantityLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *firstTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *secondTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *thirdTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *firstUnitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *secondUnitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *thirdUnitLabel;

@end

@implementation ESProductDetailEarnestCell
{
    NSTimeInterval _timeInterval;
    NSTimer *_timer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.firstTimeLabel.layer.masksToBounds = YES;
    self.firstTimeLabel.layer.cornerRadius = 4.0f;
    self.secondTimeLabel.layer.masksToBounds = YES;
    self.secondTimeLabel.layer.cornerRadius = 4.0f;
    self.thirdTimeLabel.layer.masksToBounds = YES;
    self.thirdTimeLabel.layer.cornerRadius = 4.0f;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductEarnestInfoAtIndexPath:)])
    {
        ESProductDetailEarnestModel *model = [(id)self.cellDelegate getProductEarnestInfoAtIndexPath:indexPath];
        if (model
            && [model isKindOfClass:[ESProductDetailEarnestModel class]])
        {
            self.priceLabel.text = [@"¥" stringByAppendingString:model.activityPrice];
            self.placeQuantityLabel.text = [NSString stringWithFormat:@"%@人已预订", model.placeQuantity];
    
            self.unstartView.hidden = model.isEarnestStart;
            self.startView.hidden = !model.isEarnestStart;

            _timeInterval = [model.earnestDexTime doubleValue]/1000;
            if (_timeInterval > 0)
            {
                [self updateUnits];
                
                if (_timer)
                {
                    [_timer invalidate];
                    _timer = nil;
                }
                
                [self updateTimeLabels];
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                  target:self
                                                                selector:@selector(autoCountDown)
                                                                userInfo:nil
                                                                 repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                _timer = timer;
                
                if ([self.cellDelegate respondsToSelector:@selector(earnestCountDownTimerDidCreated:)])
                {
                    [(id)self.cellDelegate earnestCountDownTimerDidCreated:timer];
                }
            }
        }
    }
}

- (void)updateTimeLabels
{
    NSInteger seconds = _timeInterval;
    NSInteger days = seconds/(3600 * 24);
    
    NSString *firstText = nil;
    NSString *secondText = nil;
    NSString *thirdText = nil;
    if (days > 0)
    {
        firstText = [NSString stringWithFormat:@"%02ld",seconds/(3600 * 24)];
        secondText = [NSString stringWithFormat:@"%02ld",(seconds%(3600 * 24)/3600)];
        thirdText = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    }
    else
    {
        firstText = [NSString stringWithFormat:@"%02ld",seconds/(3600)];
        secondText = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
        thirdText = [NSString stringWithFormat:@"%02ld",seconds%60];
    }
    
    self.firstTimeLabel.text = firstText;
    self.secondTimeLabel.text = secondText;
    self.thirdTimeLabel.text = thirdText;
}

- (void)updateUnits
{
    NSInteger seconds = _timeInterval;
    NSInteger days = seconds/(3600 * 24);
    if (days > 0)
    {
        self.firstUnitLabel.text  = @"天";
        self.secondUnitLabel.text = @"时";
        self.thirdUnitLabel.text  = @"分";
    }
    else
    {
        self.firstUnitLabel.text  = @"时";
        self.secondUnitLabel.text = @"分";
        self.thirdUnitLabel.text  = @"秒";
    }
}

- (void)autoCountDown
{
    if (_timeInterval <= 0)
    {
        [_timer invalidate];
        _timer = nil;
        if (self.cellDelegate
            && [self.cellDelegate respondsToSelector:@selector(earnestCountDownDidOver)])
        {
            [(id)self.cellDelegate earnestCountDownDidOver];
        }
    }
    else
    {
        _timeInterval -= 1;
        [self updateTimeLabels];
    }
}

@end
