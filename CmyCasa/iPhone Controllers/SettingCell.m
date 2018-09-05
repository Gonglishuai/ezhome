//
//  iphoneSettingCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "SettingCell.h"

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)showLoginNeededAlert{
    
    [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"err_msg_login_before_email_status", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn",@"") otherButtonTitles: nil] show];
    
}

- (IBAction)switchSendInfoPressed:(id)sender {
  
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [[UserManager sharedInstance] updatePreference:self.cellType withStatus:self.settingToggle.on];
    }else{
        if (self.cellType == kDataCollect) {
            [[UserManager sharedInstance] updatePreference:self.cellType withStatus:self.settingToggle.on];
        }else{
            [self showLoginNeededAlert];
            self.settingToggle.on = !self.settingToggle.on;
        }
    }
}


@end
