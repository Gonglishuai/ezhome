//
//  MessagesHeaderView.m
//  Homestyler
//
//  Created by liuyufei on 5/4/18.
//

#import "MessagesHeaderView.h"

@interface MessagesHeaderView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *latestMessages;

@end

@implementation MessagesHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.latestMessages.text = [NSString stringWithFormat:@"%@ 🔔", NSLocalizedString(@"notify_list_new_tag", nil)];
    self.textLeftConstraint.constant = IS_IPAD ? 40 : 20;
}

@end
