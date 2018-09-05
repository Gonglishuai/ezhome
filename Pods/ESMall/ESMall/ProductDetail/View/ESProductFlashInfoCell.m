
#import "ESProductFlashInfoCell.h"
#import "ESFlashSaleInfoModel.h"

@interface ESProductFlashInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

@property (weak, nonatomic) IBOutlet UIView *unStartBackgroundView;

@property (weak, nonatomic) IBOutlet UIView *startBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstUnit;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondUnit;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdUnit;

@end

@implementation ESProductFlashInfoCell
{
    NSTimeInterval _timeInterval;
    NSTimer *_timer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.hourLabel.layer.masksToBounds = YES;
    self.hourLabel.layer.cornerRadius = 4.0f;
    self.minLabel.layer.masksToBounds = YES;
    self.minLabel.layer.cornerRadius = 4.0f;
    self.secLabel.layer.masksToBounds = YES;
    self.secLabel.layer.cornerRadius = 4.0f;
    
    self.tagLabel.layer.masksToBounds = YES;
    self.tagLabel.layer.cornerRadius = 2.0f;
    self.tagLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tagLabel.layer.borderWidth = 0.5f;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductFlashInfoAtIndexPath:)])
    {
        ESFlashSaleInfoModel *model = [(id)self.cellDelegate getProductFlashInfoAtIndexPath:indexPath];
        
        if (model
            && [model isKindOfClass:[ESFlashSaleInfoModel class]])
        {
            self.titleLabel.text = model.productName;
            
            self.tagLabel.text = [[@" " stringByAppendingString:model.activityName] stringByAppendingString:@" "];
            
            self.salePriceLabel.text = [@"¥" stringByAppendingString:model.salePrice];
            self.stockQuantityLabel.text = [@"剩余库存:" stringByAppendingString:model.stockQuantity];
            
            NSString *itemPrice = [@"¥" stringByAppendingString:model.itemPrice];
            NSAttributedString *attrStr =
            [[NSAttributedString alloc]initWithString:itemPrice
                                           attributes:@{
                                                    NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
                                                    NSStrikethroughColorAttributeName:[UIColor whiteColor]
                                                    }];
            
            self.itemPriceLabel.attributedText = attrStr;
            
            BOOL isStart = [model.isStart boolValue];
            self.unStartBackgroundView.hidden = isStart;
            self.startBackgroundView.hidden = !isStart;
            if (isStart)
            {
                _timeInterval = [model.dexTime doubleValue]/1000;
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
                
                if ([self.cellDelegate respondsToSelector:@selector(countDownTimerDidCreated:)])
                {
                    [(id)self.cellDelegate countDownTimerDidCreated:timer];
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
    
    self.hourLabel.text = firstText;
    self.minLabel.text = secondText;
    self.secLabel.text = thirdText;
}

- (void)updateUnits
{
    NSInteger seconds = _timeInterval;
    NSInteger days = seconds/(3600 * 24);
    if (days > 0)
    {
        self.firstUnit.text  = @"天";
        self.secondUnit.text = @"时";
        self.thirdUnit.text  = @"分";
    }
    else
    {
        self.firstUnit.text  = @"时";
        self.secondUnit.text = @"分";
        self.thirdUnit.text  = @"秒";
    }
}

- (void)autoCountDown
{
    if (_timeInterval <= 0)
    {
        [_timer invalidate];
        _timer = nil;
        if (self.cellDelegate
            && [self.cellDelegate respondsToSelector:@selector(countDownDidOver)])
        {
            [(id)self.cellDelegate countDownDidOver];
        }
    }
    else
    {
        _timeInterval -= 1;
        [self updateTimeLabels];
    }
}

@end
