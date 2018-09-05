
#import "ESProductPromiseCell.h"

@interface ESProductPromiseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *promiseIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *promissIconLabel;

@end

@implementation ESProductPromiseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    if (SCREEN_WIDTH <= 320)
    {
        self.promissIconLabel.font = [UIFont stec_headerFount];
    }
}

- (void)updatePromiseItemWithDict:(NSDictionary *)dictIconAndTitle
{
    if(dictIconAndTitle
       && [dictIconAndTitle isKindOfClass:[NSDictionary class]]
       && [dictIconAndTitle[@"icon"] isKindOfClass:[NSString class]]
       && [dictIconAndTitle[@"title"] isKindOfClass:[NSString class]])
    {
        self.promiseIconImageView.image = [UIImage imageNamed:dictIconAndTitle[@"icon"]];
        self.promissIconLabel.text = dictIconAndTitle[@"title"];
    }
}

@end
