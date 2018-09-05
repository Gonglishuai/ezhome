
#import "ESCaseFittingRoomListTitleView.h"

@implementation ESCaseFittingRoomListTitleView

+ (instancetype)caseFittingRoomListTitleView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESCaseFittingRoomList"
                                                   owner:self
                                                 options:nil];
    return [array lastObject];
}

@end
