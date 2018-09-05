
#import <UIKit/UIKit.h>

@interface CoLinkPageImageView : UIView

+ (instancetype)linkPageImageView;

@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end
