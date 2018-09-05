
#import <UIKit/UIKit.h>

@interface MPOrderEmptyView : UIView

/// the label for showing information.
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

/// the layout constraint of imageView.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewY;

/// the imageView for showing image.
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end
