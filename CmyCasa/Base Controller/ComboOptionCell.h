//
//  ComboOptionCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/1/14.
//
//

#import <UIKit/UIKit.h>

@class UserComboDO;

@interface ComboOptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *comboTitle;
@property (weak, nonatomic) IBOutlet UIImageView *selectionIcon; //Not relevant for iPhone. If it's not neccecery on the iPad, it can be removed
@property (weak, nonatomic) IBOutlet UILabel *selectedIcon;

- (void)initWithComboData:(UserComboDO *)aDo;
- (void)updateSelection:(BOOL)selected;
@end
