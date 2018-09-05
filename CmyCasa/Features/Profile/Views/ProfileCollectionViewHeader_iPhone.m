//
//  ProfileCollectionViewHeader_iPhone.m
//  EZHome
//
//  Created by Eric Dong on 27/3/18.
//

#import "ProfileCollectionViewHeader_iPhone.h"

@interface ProfileCollectionViewHeader_iPhone()
@property (weak, nonatomic) IBOutlet UIButton *bigImageMode;
@property (weak, nonatomic) IBOutlet UIButton *smallImageMode;
@end


@implementation ProfileCollectionViewHeader_iPhone

- (void)awakeFromNib {
    [super awakeFromNib];

    self.bigImageMode.selected = YES;
}

#pragma mark - Action
- (IBAction)changeViewMode:(UIButton *)sender {
    if (!sender.selected) {
        self.smallImageMode.selected = !self.smallImageMode.selected;
        self.bigImageMode.selected = !self.smallImageMode.selected;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setViewDisplayMode:)]) {
            [self.delegate setViewDisplayMode:self.bigImageMode.selected ? BigMode : SmallMode];
        }
    }
}

@end
