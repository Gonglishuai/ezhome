
#import "ESTransactionDetailCell.h"
#import "ESTransactionDetailModel.h"

@interface ESTransactionDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *payWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ESTransactionDetailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getDetailDataWithIndexPath:)])
    {
        ESTransactionDetailModel *model = [self.cellDelegate getDetailDataWithIndexPath:indexPath];
        self.titleLabel.text  = model.payMethod;
        self.amountLabel.text = [NSString stringWithFormat:@"金额：¥%@", model.payAmount];
        self.numLabel.text    = [NSString stringWithFormat:@"交易流水号：%@", model.orderSerialNumber];
        self.payWayLabel.text = [NSString stringWithFormat:@"支付方式：%@", model.payMethod];
        self.timeLabel.text   = [NSString stringWithFormat:@"交易时间：%@", model.payTime];
    }
}

@end
