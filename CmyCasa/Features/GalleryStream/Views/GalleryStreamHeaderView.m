//
//  GalleryStreamHeaderView.m
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import "GalleryStreamHeaderView.h"

#import "UIImage+Tint.h"

@interface GalleryStreamHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *filterArrowIcon;

@property (strong, nonatomic) UIImage *roomTypesNormalImage;
@property (strong, nonatomic) UIImage *roomTypesExpandedImage;

@end

@implementation GalleryStreamHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    if (self.filterListButton != nil) {
        // reset button title
        [self.filterListButton setTitle:@"" forState:UIControlStateNormal];
    }

    if (self.roomTypesButton != nil) {
        self.roomTypesNormalImage = [self.roomTypesButton imageForState:UIControlStateNormal];
        self.roomTypesExpandedImage = [self.roomTypesNormalImage tintedImageWithColor:self.roomTypesButton.tintColor]; //[self.roomTypesNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (IBAction)showFilterList:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showFilterList:)])
    {
        self.filterArrowIcon.highlighted = YES;
        [self.delegate showFilterList:sender];
    }
}

- (void)setRoomType:(NSString *)text
{

}

- (void)setFilterType:(NSString *)text
{
    [self.filterListButton setTitle:text forState:UIControlStateNormal];
}

- (void)setFilterButtonState:(BOOL)expanded {
    self.filterArrowIcon.highlighted = expanded;
}

- (void)setRoomTypesButtonState:(BOOL)expanded {
    [self.roomTypesButton setImage:(expanded ? self.roomTypesExpandedImage : self.roomTypesNormalImage) forState:UIControlStateNormal];
}

@end
