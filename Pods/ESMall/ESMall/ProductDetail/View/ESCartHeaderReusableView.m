
#import "ESCartHeaderReusableView.h"

@interface ESCartHeaderReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@end

@implementation ESCartHeaderReusableView

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateHeaderAtSection:(NSInteger)section
{
    if (self.headerDelegate
        && [self.headerDelegate respondsToSelector:@selector(getCartHeaderTitleAtSection:)])
    {
        NSString *title = [self.headerDelegate getCartHeaderTitleAtSection:section];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            self.headerTitleLabel.text = title;
        }
    }
}

@end
