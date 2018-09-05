//
//  iphoneSettingCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <UIKit/UIKit.h>


@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingName;
@property (weak, nonatomic) IBOutlet UISwitch *settingToggle;
@property(nonatomic) SettingsCellType cellType;

- (IBAction)switchSendInfoPressed:(id)sender;
@end
