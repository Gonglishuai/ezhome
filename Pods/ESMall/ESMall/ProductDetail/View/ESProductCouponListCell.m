
#import "ESProductCouponListCell.h"
#import "ESProductDetailCouponsModel.h"
#import "ESProductCouponItemView.h"

@interface ESProductCouponListCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *itemBackgroundView;

@end

@implementation ESProductCouponListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getCouponListDataWithIndexPath:)])
    {
        ESProductDetailCouponsModel *model = [self.cellDelegate getCouponListDataWithIndexPath:indexPath];
        if (model
            && [model isKindOfClass:[ESProductDetailCouponsModel class]])
        {
            self.nameLabel.text = model.name;
            
            [self.itemBackgroundView layoutIfNeeded];
            
            [self updateCoupons:model.listArr];
        }
    }
}

- (void)updateCoupons:(NSArray *)array
{
    if (!array
        || ![array isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (NSDictionary *item in array)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            CGRect viewFrame = CGRectMake(
                                          [item[@"x"] floatValue],
                                          [item[@"y"] floatValue],
                                          [item[@"width"] floatValue],
                                          [item[@"height"] floatValue]
                                          );
            ESProductCouponItemView *view = [[ESProductCouponItemView alloc] initWithFrame:viewFrame itemName:item[@"message"]];
            [self.itemBackgroundView addSubview:view];
        }
    }
}

@end
