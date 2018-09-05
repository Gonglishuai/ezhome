
#import "MPBaseViewController.h"
@interface SHQRCodeReader : MPBaseViewController
@property (nonatomic, strong)UIView *viewPreview;
/// the block for finish.
@property (nonatomic ,copy) void (^dict)(NSDictionary *dict);

- (void)stopReading;
- (void)startReading;
- (void)setNavigationTitleText:(NSString *)titleText;
- (UIImage *)createImageWithColor: (UIColor *) color;
@end
