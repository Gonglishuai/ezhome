
#import "ESCreateButtonCell.h"

@interface ESCreateButtonCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation ESCreateButtonCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getButtonCellDisplayMessageWith:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getButtonCellDisplayMessageWith:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            NSString *message = dict[@"message"];
            NSString *title = nil;
            UIColor *titleColor = nil;
            if (message
                && [message isKindOfClass:[NSString class]]
                && message.length > 0)
            {
                title = message;
                titleColor = [UIColor stec_titleTextColor];
            }
            else
            {
                title = dict[@"placeholder"]?dict[@"placeholder"]:@"";
                titleColor = [UIColor stec_contentTextColor];
            }
            [self.messageButton setTitle:title
                                forState:UIControlStateNormal];
            [self.messageButton setTitleColor:titleColor
                                     forState:UIControlStateNormal];
            
            self.titleLabel.text = dict[@"title"];
            self.bottomLine.hidden = ![dict[@"showLine"] boolValue];
        }
    }
}

- (IBAction)messageButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(messageButtonDidTappedWithIndexPath:)])
    {
        [(id)self.cellDelegate messageButtonDidTappedWithIndexPath:_indexPath];
    }
}

@end
