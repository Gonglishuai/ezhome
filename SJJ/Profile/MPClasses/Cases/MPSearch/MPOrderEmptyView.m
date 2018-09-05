
#import "MPOrderEmptyView.h"

@implementation MPOrderEmptyView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageViewY.constant = (200/667.0) * SCREEN_HEIGHT;
    self.backgroundColor = [UIColor stec_viewBackgroundColor];
}

@end
