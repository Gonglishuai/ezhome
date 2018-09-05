//
//  ProductInfoBrightnessTableViewCell.m
//  Homestyler
//
//  Created by Dan Baharir on 11/18/14.
//
//

#import "ProductInfoBrightnessTableViewCell.h"

@implementation ProductInfoBrightnessTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)resetBrightness:(id)sender {
    // reseting the slider to default (entity brightness resets at productTagBaseView method)
    [self.brightnessSlider setValue:ENTITY_DEFAULT_BRIGHTNESS ];
}
@end
