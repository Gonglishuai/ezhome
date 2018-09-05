
#import "ESTouchImageView.h"
#import "UIImageView+WebCache.h"

@implementation ESTouchImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    
    self.userInteractionEnabled = YES;
}

- (void)updateImageViewWithUrlStr:(NSString *)urlStr
{
    if (!urlStr
        || ![urlStr isKindOfClass:[NSString class]]
        || urlStr.length <= 0)
    {
        self.image = [UIImage imageNamed:@"image_default"];
        return;
    }

    [self sd_setImageWithURL:[NSURL URLWithString:urlStr]
            placeholderImage:[UIImage imageNamed:@"image_default"]];
}

@end
