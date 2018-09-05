
#import "ESCaseFittingModelTagLabel.h"

@implementation ESCaseFittingModelTagLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2.0f;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont stec_tagFount];
    self.textAlignment = NSTextAlignmentCenter;
}

@end
