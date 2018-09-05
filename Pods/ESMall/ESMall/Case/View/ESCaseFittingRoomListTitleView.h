
#import <UIKit/UIKit.h>

@interface ESCaseFittingRoomListTitleView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UIView *spaceView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottom;

+ (instancetype)caseFittingRoomListTitleView;

@end
