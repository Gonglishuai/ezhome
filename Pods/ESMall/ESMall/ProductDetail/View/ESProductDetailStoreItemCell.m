
#import "ESProductDetailStoreItemCell.h"
#import "ESProductStoreModel.h"

@interface ESProductDetailStoreItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIImageView *callImageView;

@end

@implementation ESProductDetailStoreItemCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.callButton setTitleColor:[UIColor stec_blueTextColor]
                          forState:UIControlStateNormal];
    [self.callButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductStoreInformationAtIndexPath:)])
    {
        ESProductStoreModel *model = [(id)self.cellDelegate getProductStoreInformationAtIndexPath:indexPath];
        if (model
            && [model isKindOfClass:[ESProductStoreModel class]])
        {
            self.titleLabel.text = model.storeName;
            [self.callButton setTitle:model.mobile
                             forState:UIControlStateNormal];
            self.callButton.enabled = model.callStatus;
            self.callButton.titleLabel.font = model.callStatus?[UIFont stec_phoneNumberFount]:[UIFont stec_subTitleFount];
            self.callImageView.highlighted = model.callStatus;
        }
    }
}

- (IBAction)navigationButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(productStoreNavigationButtonDidTappedWithIndexPath:)])
    {
        [(id)self.cellDelegate productStoreNavigationButtonDidTappedWithIndexPath:_indexPath];
    }
}

- (IBAction)callButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(productStoreCallButtonDidTappedWithIndexPath:)])
    {
        [(id)self.cellDelegate productStoreCallButtonDidTappedWithIndexPath:_indexPath];
    }
}

@end
