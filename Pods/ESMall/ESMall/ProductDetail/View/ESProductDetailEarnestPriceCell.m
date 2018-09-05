
#import "ESProductDetailEarnestPriceCell.h"
#import "ESProductDetailEarnestModel.h"

@interface ESProductDetailEarnestPriceCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *earnestAmountLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *discountLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *finalPaymentAmountLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *finalPaymentTimeLabel;

@end

@implementation ESProductDetailEarnestPriceCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
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
            
            self.earnestAmountLabel.text = [@"¥" stringByAppendingString:model.earnestAmount];
            self.finalPaymentAmountLabel.text = [@"¥" stringByAppendingString:model.finalPaymentAmount];
            self.discountLabel.text = [@"¥" stringByAppendingString:model.discountAmount];
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM月dd日 HH:mm"];
            NSDate *finalStartDate = [NSDate dateWithTimeIntervalSince1970:[model.finalPaymentStartTime doubleValue]/1000];
            NSString *finalStartDateStr = [dateFormat stringFromDate:finalStartDate];
            NSDate *finalEndDate = [NSDate dateWithTimeIntervalSince1970:[model.finalPaymentEndTime doubleValue]/1000];
            NSString *finalEndDateStr = [dateFormat stringFromDate:finalEndDate];
            self.finalPaymentTimeLabel.text = [NSString stringWithFormat:@"(%@-%@)",finalStartDateStr,finalEndDateStr];
        }
    }
}

@end
