//
//  GalleryStreamHeadView.m
//  EZHome
//
//  Created by liuyufei on 4/16/18.
//

#import "GalleryStreamHeaderView_iPhone.h"
#import "RoomTypeDO.h"

@interface GalleryStreamHeaderView_iPhone()

@property (weak, nonatomic) IBOutlet UIButton *roomTypeListButton;
@property (weak, nonatomic) IBOutlet UIImageView *roomTypesArrowIcon;

@end

@implementation GalleryStreamHeaderView_iPhone

- (void)awakeFromNib {
    [super awakeFromNib];
    // reset button title
    [self.roomTypeListButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)setSortTypesArr:(NSArray *)sortTypesArr
{
    if (sortTypesArr.count > 0 && self.filterListButton.titleLabel.text.length == 0)
    {
         [self.filterListButton setTitle:[sortTypesArr[0] objectForKey:@"d"] forState:UIControlStateNormal];
    }
}

- (void)setRoomTypesArr:(NSArray *)roomTypesArr
{
    if (roomTypesArr.count > 0 && self.roomTypeListButton.titleLabel.text.length == 0)
    {
        [self.roomTypeListButton setTitle:NSLocalizedString(@"all_filter", @"All") forState:UIControlStateNormal];
    }

}

- (IBAction)showRoomTypeList:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showRoomTypeList:)])
    {
        [self setRoomTypesButtonState:YES];
        [self.delegate showRoomTypeList:sender];
    }
}

- (void)setRoomType:(NSString *)text
{
    [super setRoomType:text];
    [self.roomTypeListButton setTitle:text forState:UIControlStateNormal];
}

- (void)setRoomTypesButtonState:(BOOL)expanded {
    self.roomTypesArrowIcon.highlighted = expanded;
}

@end
