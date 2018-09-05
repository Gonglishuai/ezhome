
#import "CoLinkPageImageView.h"

@interface CoLinkPageImageView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnHeight;

@end

@implementation CoLinkPageImageView

+ (instancetype)linkPageImageView
{
    NSArray *array = [[NSBundle mainBundle]
                      loadNibNamed:@"CoLinkPageImageView"
                      owner:self
                      options:nil];
    
    return [array firstObject];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.btnBottom.constant = 22.0f * (667 /(SCREEN_HEIGHT * 1.0));
    self.btnWidth.constant = 130 * SCREEN_SCALE;
    self.btnHeight.constant = 40 * SCREEN_SCALE;
    self.imageView.image = _image;
}

@end
