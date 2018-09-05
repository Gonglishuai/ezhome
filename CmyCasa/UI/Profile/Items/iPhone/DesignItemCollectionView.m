//
//  DesignItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "DesignItemCollectionView.h"
#import "UIImageView+URLLoader.h"
#import "NotificationNames.h"
#import "MyDesignDO.h"

@interface DesignItemCollectionView ()

- (IBAction)designPressed;
- (IBAction)editPressed;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *designImage;
@property (weak, nonatomic) IBOutlet UIButton *ribbonButton;

@end

@implementation DesignItemCollectionView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.containerView.hidden = YES;
    self.ribbonButton.hidden = YES;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(designStatusChanged:) name:kNotificationMyDesignDOStatusChanged object:nil];
}

- (void)setDesign:(MyDesignDO *)design
{
    _design = design;
    
    if (design)
    {
        self.containerView.hidden = NO;
        self.ribbonButton.hidden = !self.isCurrentUserDesign;
        
        if (self.isCurrentUserDesign) {
            self.ribbonButton.hidden=[design isDesignPublished];
        }
        self.titleLabel.text = design.title;
        
        [self.designImage loadImageWithUrl:design.url usingTimestamp:[design getAPITimestamp]];
      
        [self refreshDesignStatus];
    }
    else
    {
        self.containerView.hidden = YES;
    }
}

- (void)designStatusChanged:(NSNotification *)notification
{
    NSString *designId = [[notification userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([designId isEqualToString:self.design._id])
    {
        [self refreshDesignStatus];
    }
}

- (void)refreshDesignStatus
{
    if (_design)
    {
        switch (_design.publishStatus) {
            case STATUS_PRIVATE:
                self.statusLabel.text = NSLocalizedString(@"design_private", @"Private design");
                self.statusLabel.textColor = [UIColor colorWithRed:198/255.0 green:34/255.0 blue:41/255.0 alpha:1];
                break;
            case STATUS_PUBLIC:
                self.statusLabel.text = NSLocalizedString(@"design_public", @"Public design");
                self.statusLabel.textColor = [UIColor colorWithWhite:89/255.0 alpha:1];
                break;
            case STATUS_PUBLISHED:
                self.statusLabel.text = NSLocalizedString(@"design_published", @"Published design");
                self.statusLabel.textColor = [UIColor colorWithRed:99/255.0 green:170/255.0 blue:2/255.0 alpha:1];
                break;
            default:
                break;
        }
    }
}

- (IBAction)designPressed
{
    [self.delegate designPressed:self.design];
}

- (IBAction)editPressed
{
    [self.delegate designEditPressed:self.design];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
