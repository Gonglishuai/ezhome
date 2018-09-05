
#import "ESModelFilterReusableView.h"

@interface ESModelFilterReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@end

@implementation ESModelFilterReusableView

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateFilterHeaderViewWithSection:(NSInteger)section
{
    if (self.headerDelegate
        && [self.headerDelegate respondsToSelector:@selector(getFilterHeaderTitleAtSection:)])
    {
        NSString *title = [self.headerDelegate getFilterHeaderTitleAtSection:section];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            self.headerTitleLabel.text = title;
        }
    }
}

@end
