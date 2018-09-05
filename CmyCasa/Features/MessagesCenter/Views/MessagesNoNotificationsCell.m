//
//  MessagesNoNotificationsCell.m
//  Homestyler
//
//  Created by liuyufei on 5/7/18.
//

#import "MessagesNoNotificationsCell.h"

@interface MessagesNoNotificationsCell()

@property (weak, nonatomic) IBOutlet UILabel *noNotifications;

@end

@implementation MessagesNoNotificationsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.noNotifications.text = NSLocalizedString(@"notify_list_no", nil);
}

@end
