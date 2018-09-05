
#import "ESConstructListCell.h"
#import "ESConstructModel.h"

@interface ESConstructListCell ()

@property (weak, nonatomic) IBOutlet UILabel *projectNumerLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *housingEstateLabel;

@property (weak, nonatomic) IBOutlet UIView *detailBackgroundView;

@end

@implementation ESConstructListCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.detailBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(detailDidTapped)]];
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getConstructDataWithIndexPath:)])
    {
        ESConstructModel *model = [self.cellDelegate getConstructDataWithIndexPath:indexPath];
        if (model
            && [model isKindOfClass:[ESConstructModel class]])
        {
            self.projectNumerLabel.text = [NSString stringWithFormat:@"项目编号：%@",
                                           [ESConstructListCell checkValue:model.projectNum]];
            self.nameLabel.text = [NSString stringWithFormat:@"姓名：%@",
                                   [ESConstructListCell checkValue:model.ownerName]];
            self.phoneLabel.text = [NSString stringWithFormat:@"手机号码：%@", [ESConstructListCell checkValue:model.phoneNum]];
            self.housingEstateLabel.text = [NSString stringWithFormat:@"小区名称：%@",
                                       [ESConstructListCell checkValue:model.housingEstate]];
            self.addressLabel.text = [NSString stringWithFormat:@"项目地址：%@",
                                      [ESConstructListCell checkValue:model.address]];
        }
    }
}

+ (NSString *)checkValue:(NSString *)value
{
    if (!value
        || ![value isKindOfClass:[NSString class]])
    {
        return @"暂无数据";
    }
    
    return value;
}

#pragma mark - Tap Method
- (void)detailDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(constructDetailDidTapped:)])
    {
        [self.cellDelegate constructDetailDidTapped:_indexPath];
    }
}

@end
