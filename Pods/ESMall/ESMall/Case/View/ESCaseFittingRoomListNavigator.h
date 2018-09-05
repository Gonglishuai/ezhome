
#import <UIKit/UIKit.h>

@protocol ESCaseFittingRoomListNavigatorDelegate <NSObject>

- (void)backButtonDidTapped;

@end

@interface ESCaseFittingRoomListNavigator : UIView

@property (nonatomic, assign) id<ESCaseFittingRoomListNavigatorDelegate>delegate;

@property (weak, nonatomic) IBOutlet UILabel *navigatorTitleLabel;

+ (instancetype)caseFittingRoomListNavigator;

@end
