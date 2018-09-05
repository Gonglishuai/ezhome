
#import "ESPaySwitchCell.h"

@interface ESPaySwitchCell ()

@property (weak, nonatomic) IBOutlet UISwitch *paySwitch;
@property (weak, nonatomic) IBOutlet UIImageView *switchDisabelImgView;

@end

@implementation ESPaySwitchCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPaySwitchDataWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPaySwitchDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"switchOn"])
        {
            [self.paySwitch setOn:[dict[@"switchOn"] boolValue] animated:YES];
        }
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"switchEnabel"])
        {
            BOOL enabel = [[dict objectForKey:@"switchEnabel"] boolValue];
            self.paySwitch.hidden = !enabel;
            self.switchDisabelImgView.hidden = enabel;
        }
    }
}

- (IBAction)switchDidChangeValue:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(switchValueDidChanged:indexPath:)])
    {
        [(id)self.cellDelegate switchValueDidChanged:self.paySwitch.isOn
                                           indexPath:_indexPath];
    }
}

@end
