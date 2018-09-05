//
//  ProfileTabCell-iPad.m
//  Homestyler
//
//  Created by Ma'ayan on 12/16/13.
//
//

#import "ProfileTabCell.h"
#import "UIView+NUI.h"

@interface ProfileTabCell ()

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UIView *selectionView;

@end

@implementation ProfileTabCell

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

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.lblTitle.text = @"";
    self.lblCount.text = @"";
    self.lblCount.hidden = NO;
    [self.btnIcon setSelected:NO];
    [self.btnIcon setTitle:@"" forState:UIControlStateNormal];
}

- (void)setWithTitle:(NSString *)title counter:(NSString *)counter andSelected:(BOOL)isSelected iconString:(NSString *)iconString {
    self.lblTitle.text = title;
    self.lblTitle.highlighted = isSelected;
    self.lblCount.text = counter;
    self.lblCount.highlighted = isSelected;
    [self.btnIcon setSelected:isSelected];
    
    if (counter == nil)
    {
        self.lblCount.hidden = YES;
    }
    
    [self.btnIcon.titleLabel setFont:[UIFont fontWithName:@"homestylermainicons" size:18]];
    [self.btnIcon setTitle:iconString forState:UIControlStateNormal];
    self.selectionView.hidden = !isSelected;
}

//Useless for the iPad. Stayed only for iPhone support
- (void)setWithTitle:(NSString *)title counter:(NSString *)counter andSelected:(BOOL)isSelected icon:(UIImage *)iconImage {

    self.lblTitle.text = title;
    self.lblTitle.highlighted = isSelected;
    self.lblCount.text = counter;
    self.lblCount.highlighted = isSelected;
    [self setSelected:isSelected];
    
    if (counter == nil)
    {
        self.lblCount.hidden = YES;
    }
    
    self.selectionView.hidden = !isSelected;
}

@end
