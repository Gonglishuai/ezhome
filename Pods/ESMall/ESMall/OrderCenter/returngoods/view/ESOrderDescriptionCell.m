//
//  ESOrderDescriptionCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderDescriptionCell.h"

@implementation ESOrderDescriptionCell
{
    __weak IBOutlet UILabel *_descriptionLabel;

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateDescriptionCell {
    if ([self.delegate respondsToSelector:@selector(getDescription)]) {
        _descriptionLabel.text = [self.delegate getDescription];
    }
}

@end
