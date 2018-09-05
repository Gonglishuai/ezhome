//
//  ComboOptionCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/1/14.
//
//

#import "ComboOptionCell.h"
#import "UserComboDO.h"

@implementation ComboOptionCell

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

    // Configure the view for the selected state
}

- (void)initWithComboData:(UserComboDO *)aDo {

    self.comboTitle.text=aDo.comboName;
    [self setSelected:YES];

}
- (void)updateSelection:(BOOL)selected{
    
    self.selectionIcon.hidden=!selected;
    self.selectedIcon.hidden = !selected;
}

@end
