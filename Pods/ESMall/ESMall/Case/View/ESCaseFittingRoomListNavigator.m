
#import "ESCaseFittingRoomListNavigator.h"

@implementation ESCaseFittingRoomListNavigator

+ (instancetype)caseFittingRoomListNavigator
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESCaseFittingRoomList"
                                                   owner:self
                                                 options:nil];
    return [array firstObject];
}

- (IBAction)backButtonDidTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(backButtonDidTapped)])
    {
        [self.delegate backButtonDidTapped];
    }
}

@end
